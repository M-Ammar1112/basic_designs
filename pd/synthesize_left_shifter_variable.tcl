set project_name "left_shifter_variable"
set revision_name "left_shifter_variable"
set top_entity   "left_shifter_variable"
set family       "Agilex 5"
set device       "A5EA005BB15AE4S"

set script_dir [file dirname [file normalize [info script]]]
file mkdir [file join $script_dir output_files]
cd $script_dir

if {[project_exists $project_name]} {
    project_open $project_name -revision $revision_name
} else {
    project_new $project_name -revision $revision_name -overwrite
}

remove_all_global_assignments -name VERILOG_FILE
set_global_assignment -name FAMILY $family
set_global_assignment -name DEVICE $device
set_global_assignment -name TOP_LEVEL_ENTITY $top_entity
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name VERILOG_FILE "../rtl/sequential/left_shifter_variable.v"

export_assignments
execute_module -tool syn
project_close
exit 0
