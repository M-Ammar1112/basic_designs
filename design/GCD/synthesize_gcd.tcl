# =============================================================================
# Quartus synthesis script for the GCD design (datapath + controller + top)
#
# Usage (from this directory):
#   quartus_sh -t synthesize_gcd.tcl
#
# With an absolute Quartus path (example on this machine):
#   /home/ammar/altera_pro/26.1.1/quartus/bin/quartus_sh -t synthesize_gcd.tcl
#
# Steps performed:
#   1. Open / create the gcd project in this folder
#   2. Point Quartus at gcd_datapath / gcd_controller / gcd_top
#   3. Set top entity to gcd_top
#   4. Run Analysis & Synthesis
#   5. Write reports/gcd_synthesis_summary.txt for the lab write-up
#
# After a successful run, open the GUI State Machine Viewer to capture the
# extracted controller FSM diagram for the report.
# =============================================================================

set project_name "gcd"
set revision_name "gcd"
set top_entity   "gcd_top"
set family       "Agilex 5"
set device       "A5EA005BB15AE4S"

set script_dir [file dirname [file normalize [info script]]]
set report_dir [file join $script_dir reports]

file mkdir $report_dir
file mkdir [file join $script_dir output_files]
cd $script_dir

if {[project_exists $project_name]} {
    project_open $project_name -revision $revision_name
} else {
    project_new $project_name -revision $revision_name -overwrite
}

# Source list (relative to the project directory)
set rtl_files [list \
    "../gcd_datapath.v" \
    "../gcd_controller.v" \
    "../gcd_top.v" \
]

# Drop previous Verilog file assignments if any exist, then re-add
remove_all_global_assignments -name VERILOG_FILE

set_global_assignment -name FAMILY $family
set_global_assignment -name DEVICE $device
set_global_assignment -name TOP_LEVEL_ENTITY $top_entity
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name STATE_MACHINE_PROCESSING "Auto"
set_global_assignment -name SAFE_STATE_MACHINE "Auto"

foreach f $rtl_files {
    set_global_assignment -name VERILOG_FILE $f
}

export_assignments

puts "================================================================"
puts " Synthesizing $top_entity  (family=$family, device=$device)"
puts "================================================================"

if {[catch {execute_module -tool syn} result]} {
    puts "ERROR: Synthesis failed: $result"
    project_close
    exit 1
}

set syn_rpt [file join $script_dir output_files ${revision_name}.syn.rpt]
set summary [file join $report_dir gcd_synthesis_summary.txt]
set summary_fd [open $summary w]

puts $summary_fd "GCD Quartus Synthesis Summary"
puts $summary_fd "Generated: [clock format [clock seconds]]"
puts $summary_fd "Project:   $project_name"
puts $summary_fd "Top:       $top_entity"
puts $summary_fd "Family:    $family"
puts $summary_fd "Device:    $device"
puts $summary_fd ""
puts $summary_fd "Full synthesis report: $syn_rpt"
puts $summary_fd ""

if {[file exists $syn_rpt]} {
    set rpt_fd [open $syn_rpt r]
    set rpt_data [read $rpt_fd]
    close $rpt_fd

    puts $summary_fd "----- Lines mentioning FSM / resources -----"
    puts $summary_fd ""
    foreach line [split $rpt_data "\n"] {
        if {[regexp -nocase {state machine|FSM|Logic utilization|Total registers|Total ALMs|Total LABs|Estimated|Encoding|Register} $line]} {
            puts $summary_fd $line
        }
    }
} else {
    puts $summary_fd "WARNING: Could not find $syn_rpt"
}

puts $summary_fd ""
puts $summary_fd "View / export the extracted state machine:"
puts $summary_fd "  1. Open design/GCD/gcd.qpf in Quartus"
puts $summary_fd "  2. Tools -> Netlist Viewers -> State Machine Viewer"
puts $summary_fd "  3. Select the controller FSM"
puts $summary_fd "  4. Capture a screenshot for the report"
puts $summary_fd ""
puts $summary_fd "Also see: Compilation Report -> Analysis & Synthesis -> State Machines"
close $summary_fd

puts "Synthesis finished successfully."
puts "Summary: $summary"
project_close
exit 0
