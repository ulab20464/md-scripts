#!/bin/bash
source /path/to/gromacs-2022.3/bin/GMXRC
#source /path/to/gromacs-2022.3/bin/GMXRC
options_md="-ntmpi 1 -ntomp 10 -update gpu -nb gpu"

# This script works on the LCC. It runs a GROMACS md simulation using LibParGen files
# $1 and $2 are the gro files, $3 is the no of steps to extend the production run by
# $name$f is the production mdp
# how-to-run: ./md_extend_polymer.sh PST TPL 100000000

name=$1-$2
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
steps=${3:-100000000}

mover(){
        mkdir $1
        mv *xvg ./$1
}


# Extend Production run
gmx_gpu convert-tpr -s $name$f.tpr -nsteps $steps -o $name$f$two.tpr
gmx_gpu mdrun -deffnm $name$f -s $name$f$two.tpr -cpi $name$f.cpt -cpo $name$f.cpt $options_md

echo 'MD done'
