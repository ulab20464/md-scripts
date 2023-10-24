#!/bin/bash
source /path/to/gromacs-2022.1/bin/GMXRC
#source /path/to/gromacs-2022.1/bin/GMXRC
options_md="-ntmpi 1 -ntomp 10 -update gpu -nb gpu"

# This script works on the LCC. It runs a GROMACS md simulation using LibParGen files
# $1 is the polymer, $2 is the solvent A, $3 is the additive B,
# $4 is the no of moles of A, $5 is the no of moles of B,
# $6 is the box size
# $name$c is the boxed gro file, $name$d is the Energy minimization mdp,
# $name$e is the NPT mdp, $name$f is the production mdp
# how-to-run: ./md_polymer_additive.sh PST TPL LME 136 10 10
# The above will put 1 polymer, 136 TPL, 10 LME, in a 10nm box

name=$1-$2-$3
boxsize=$6
one=1
two=2
three=3
c='_boxed'
d='_em'
e='_npt'
f='_md'
m='_msd'
r='_rdf'
cen='_centered'

mover(){
	mkdir $1
	mv *xvg ./$1
}

# Putting the gro file into a box 
gmx_gpu insert-molecules -ci $1.gro -o $1$c.gro -nmol 1 -box 6.0 
gmx_gpu editconf -f $1$c.gro -o $1$cen.gro -box $boxsize -c -d 1.0 -bt cubic  # center the system in a bigger box

gmx_gpu insert-molecules -ci $2.gro -f $1$cen.gro -o $1-$2$cen.gro -nmol $4
gmx_gpu insert-molecules -ci $3.gro -f $1-$2$cen.gro -o $name$c.gro -nmol $5
echo 'Gro file boxed'

# make index file
{ echo 'O'; echo q; } | gmx_gpu make_ndx -f $name$c.gro -o $name.ndx

# Energy minimization
gmx_gpu  grompp -f $one.mdp -c $name$c.gro -p $name.top -o $name$d.tpr -n $name.ndx -maxwarn 2
echo 'EM grompp done'
gmx_gpu mdrun -deffnm $name$d
echo 'EM mdrun done'

# NPT Equilibration
gmx_gpu  grompp -f $two.mdp -c $name$d.gro -p $name.top -o $name$e.tpr -n $name.ndx -maxwarn 2
echo 'NPT grompp done'
gmx_gpu mdrun -deffnm $name$e $options_md
echo 'NPT mdrun done'

# Production run
gmx_gpu  grompp -f $three.mdp -c $name$e.gro -p $name.top -o $name$f.tpr -n $name.ndx -maxwarn 2
gmx_gpu mdrun -deffnm $name$f $options_md
echo 'MD done'
