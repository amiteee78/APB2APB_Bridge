
# Setting simulation configurations to generate database & probe signals
database -open apb_bridge_tb -shm -event -into wave_database/apb_bridge_tb.shm
probe -create apb_bridge_tb -depth all -all -memories -all -variables -tasks -functions -shm -database apb_bridge_tb
run
database -close apb_bridge_tb
finish 2
