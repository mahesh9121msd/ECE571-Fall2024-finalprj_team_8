vlog +define+DEBUG apb_pkg.sv inf_apb.sv dut_apb.sv tb.sv 
vsim work.apb_mem_tb
vsim -voptargs=+acc work.apb_mem_tb
add wave -r /*
run -all
