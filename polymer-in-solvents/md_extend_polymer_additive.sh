#!/bin/bash
source /path/to/gromacs-2022.1/bin/GMXRC
#source /path/to/gromacs-2022.1/bin/GMXRC
options_md="-ntmpi 1 -ntomp 10 -update gpu -nb gpu"

# This script works on the LCC. It runs a GROMACS md simulation using LibParGen files
# $1 is the polymer, $2 is the solvent A, $3 is the additive B,
# $4 is the no of steps to run the simulation for.
# $name$f is the production mdp
# how-to-run: ./md_extend_polymer_additive.sh PST TPL LME 100000000
# The above will extend a simulation to 200ns.

name=$1-$2-$3
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
steps=${4:-100000000}

mover(){
	mkdir $1
	mv *xvg ./$1
}


# Extend Production run
gmx_gpu convert-tpr -s $name$f.tpr -nsteps $steps -o $name$f$two.tpr
gmx_gpu mdrun -deffnm $name$f -s $name$f$two.tpr -cpi $name$f.cpt -cpo $name$f.cpt $options_md

#gmx_gpu  grompp -f $three.mdp -c $name$e.gro -p $name.top -o $name$f.tpr -n $name.ndx -maxwarn 2
#gmx_gpu mdrun -deffnm $name$f $options_md
echo 'MD done'
