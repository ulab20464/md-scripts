# This is the same as filerenamer_test_v3.py
from pathlib import Path
import os, shutil, time, pandas as pd

pathway = Path()
localtime = time.asctime( time.localtime(time.time()) )


def rewrite(path):    
    split_path = os.path.split(path)
#     print(split_path[1])
    return split_path[1]
    print('\n')
    
for folder in pathway.glob('test/*'):
#     print(folder)
    new_resname = rewrite(folder)
    counter=0
    old_oplstags = set()

    for files in pathway.glob("{target}/*".format(target=folder)):
#         print(files)
        opls_lines = set()
        old_path = os.path.split(files)
#         print(old_path)
        old_resname = files.stem[0:3]
#         print(old_resname)        
        
        if files.name.__contains__(".itp"):
            new_itp = f"{new_resname}.itp"
            new_itppath = os.path.join(old_path[0],new_itp)
            # print(new_path)
            
            os.system(f"sed 's/{old_resname}/{new_resname}/g' {files} > {new_itppath}")
            with open(new_itppath, 'r') as f:  # Replace residue names with folder names
                lines = f.readlines()
                for line in lines:
                    stripped_line = line.strip()
    #                 print(stripped_line)
                    split_line = stripped_line.split(' ')
    #                 print(split_line)
                    opls = [x for x in split_line if x.__contains__('opls')]
                    if len(opls)>0:                        
                        old_oplstags.add(opls[0])                 
            
                   
            for member in (old_oplstags):
                old_tag = str(member)
                print(old_tag)
                new_oplstag = old_tag + new_resname
                print(new_oplstag)             
                os.system(f"sed -i 's/{old_tag}/{new_oplstag}/g' {new_itppath}")                                       
                print('\n')
                
            df_oplstags = []    
            with open(new_itppath, 'r') as f:  # renamed itp file being edited yet again
                lines = f.readlines()
#             print(lines)
                with open(new_itppath, 'w') as f:  # Rewrite itp file without the [ atomtypes ] section

                    with open("oplsaa.ff/ffnonbonded_new.itp", 'a') as ff:  
                        if counter < 1:
                            ff.write(f"\n\n; {new_resname} (Added by Usman & Joseph {localtime}) \n")
                            counter +=1
                        for line in lines:
                            stripped_line = line.strip()
                            split_line = stripped_line.split()                            

                            if stripped_line.__contains__('opls'):
                                if split_line[1].__contains__('opls'):
                                    df_oplstags.append(split_line)
                                    
                                if split_line[0] in opls_lines:  # This avoids adding an opls tag twice
                                    pass
                                elif split_line[0].__contains__('opls'):
                                    opls_lines.add(split_line[0])
                                    ff.write(line)

                            try:
                                if stripped_line.__contains__("atomtypes") or split_line[0].__contains__('opls'):
                                    pass
                                else:
                                    f.write(line)
                            except IndexError:
                                print("Index error when rewriting the itp file")
                                
                                
            # Charge neutralisation section                    
            df = pd.DataFrame(df_oplstags)
            # df.shape
            charges = df[6]
            charge_list = []
            abs_charge_list = []
            netcharge = 0
            for y in charges:
                charge = float(y)
                print(charge)
                charge_list.append(charge)
                netcharge += charge
                abs_charge_list.append(abs(charge))


            max_charge = max(abs_charge_list)
            print(f"Initial net charge: {netcharge}\n")
            print(f"Max charge: {charge_list[abs_charge_list.index(max_charge)]} at index {abs_charge_list.index(max_charge)}\n")

            max_charge_index = abs_charge_list.index(max_charge)
            max_charge = charge_list[max_charge_index]
            original_charge_list = charge_list.copy()

            if netcharge < 0:
                neutralizer = charge_list[max_charge_index] + abs(netcharge)
                print(f"Max charge: {max_charge} at index {max_charge_index} has been changed to {neutralizer}\n")
                charge_list[max_charge_index] = neutralizer
            elif netcharge > 0:
                neutralizer = charge_list[max_charge_index] - netcharge
                print(f"Max charge: {max_charge} at index {max_charge_index} has been changed to {neutralizer}\n")
                charge_list[max_charge_index] = neutralizer
            else:
                neutralizer = 0

            print(f"Final net charge: {sum(charge_list)}")
            sed_neutralizer = round(neutralizer, 4)
            sed_oldcharge = original_charge_list[max_charge_index]
            guilty_opls = df.iloc[max_charge_index, 1]
            print(f"The charge for {guilty_opls} should be changed from {sed_oldcharge} to {sed_neutralizer}\n")
            
            

            # This ensures columns aren't distorted when for instance a 2 decimal place charge is replaced by a 4 d.p charge
            oldcharge_str = str(sed_oldcharge)
            neutralizer_str = str(sed_neutralizer)
            space = abs(len(oldcharge_str) - len(neutralizer_str))
            if len(oldcharge_str) > len(neutralizer_str):
                adjusted_oldcharge = oldcharge_str
            elif len(neutralizer_str) > len(oldcharge_str):
                adjusted_oldcharge = oldcharge_str.rjust(space+5, ' ')
                #neutralizer_str = neutralizer_str
            else:
                adjusted_oldcharge = oldcharge_str

            os.system(f"sed -i '/{guilty_opls}/s/{adjusted_oldcharge}/{neutralizer_str}/g' {new_itppath}")
                             
                
        elif files.name.__contains__(".gro"):
            new_gro = f"{new_resname}.gro"
            new_gropath = os.path.join(old_path[0], new_gro)
            print(new_gropath)
            os.system(f"sed 's/{old_resname}/{new_resname}/g' {files} > {new_gropath}")