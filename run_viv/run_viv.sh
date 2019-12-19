reset
#Reading RTL files
xvlog --work $1_lib --sv ../rtl/*.sv ../tb/$1.sv -i ../arch_specs/ --nolog

#Elaborating the design
xelab --lib $1_lib --snapshot $1_behav $1_lib.$1 --timescale 1ns/1ns --nolog

#simulating the design
xsim $1_behav --runall --sv_seed --nolog

rm -rf *jou *log *pb
./mem_file_mod.py