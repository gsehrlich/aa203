#!/bin/sh

while read p; do
    qsub -wd /afs/ir/users/m/s/mstaib/class/aa203/final-project/ -M mstaib@stanford.edu -m bea -v lambda=${p} bash_one_lambda.sh
done <lambdas.txt
