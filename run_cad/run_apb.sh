#!/bin/csh

set test_bench = $1
set top_design = $2
set sim_invoke

# Creating Necessary Directories
if (! -d "coverage") then
	echo "\e[1;32m***The Coverage Control directory Created***\e[0m"
	mkdir coverage
endif

if (! -d "script") then
	echo "\e[1;32m***The Tcl Script directory Created***\e[0m"
	mkdir script
endif

if (! -d "wave_database") then
	echo "\e[1;32m***The Wave Database directory Created***\e[0m"
	mkdir wave_database
endif

if (! -f "coverage/$2_cov.ccf") then
# Creating coverage configuaration file
	cat > coverage/$2_cov.ccf << end_of_conf_settings

# Setting coverage configurations for coverage analysis & fsm extraction
	select_coverage -bet -module worklib.$1
	set_toggle_scoring -sv_enum
	set_expr_scoring -control
	set_expr_coverable_operators -event
	set_expr_coverable_statements -all
	set_covergroup -per_instance_default_one
	set_covergroup -new_instance_reporting
	set_fsm_scoring -hold_transition
	select_coverage -bet -file $1.sv
	select_functional
end_of_conf_settings

# Changing Permission
	chmod 775 coverage/$2_cov.ccf
endif

# Creating irun command script
cat > script/$1.tcl << end_of_ncsim_commands

# Setting simulation configurations to generate database & probe signals
database -open $1 -shm -event -into wave_database/$1.shm
probe -create $1 -depth all -all -memories -all -variables -tasks -functions -shm -database $1
run
database -close $1
finish 2
end_of_ncsim_commands

# Changing Permission
chmod 775 script/$1.tcl

# Start of Simulation
irun 	-access +rwc  \
			+fsmdebug 		\
			-disable_sem2009 \
			-timescale 1ns/1ns \
			-incdir ../arch_specs/ \
			-sv ../rtl/*.sv* \
			-sysv ../tb/$1.sv \
			-covfile coverage/$2_cov.ccf \
			-input script/$1.tcl \
			-coverage A \
			-covdut $1 \
			-covoverwrite	\
			-covtest $1_test \
			-date \
			-clean \
			-nocopyright \
			-nohistory \
			-nolog \
			-stats \

chmod 775 * -R

printf "\n"
echo "\e[1;32m***Simulation Completed***\e[0m"
printf "\n"

# Simvision Invoking Control
while ($sim_invoke != "yes" & $sim_invoke != "no")
	printf "Do you want to invoke simvision with simulation result?(yes/no):: "
	set sim_invoke = $<
end

if ($sim_invoke == "yes") then
	echo "\e[1;32m***Invoking Simvision***\e[0m"
	simvision wave_database/$1.shm/$1.trn &
else if ($sim_invoke == "no") then
	echo "\e[1;32m***Exiting Simulation***\e[0m"
	exit
endif
