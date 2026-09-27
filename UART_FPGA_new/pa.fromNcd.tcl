
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name UART_FPGA_new -dir "S:/FPGA_MINIPROJECT/UART_FPGA_new/planAhead_run_1" -part xc6slx9csg324-2
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "S:/FPGA_MINIPROJECT/UART_FPGA_new/top_module.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {S:/FPGA_MINIPROJECT/UART_FPGA_new} }
set_property target_constrs_file "S:/FPGA_MINIPROJECT/UART_FPGA_new/ucf/mimasV2.ucf" [current_fileset -constrset]
add_files [list {S:/FPGA_MINIPROJECT/UART_FPGA_new/ucf/mimasV2.ucf}] -fileset [get_property constrset [current_run]]
link_design
read_xdl -file "S:/FPGA_MINIPROJECT/UART_FPGA_new/top_module.ncd"
if {[catch {read_twx -name results_1 -file "S:/FPGA_MINIPROJECT/UART_FPGA_new/top_module.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"S:/FPGA_MINIPROJECT/UART_FPGA_new/top_module.twx\": $eInfo"
}
