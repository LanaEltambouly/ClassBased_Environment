vlib work
vlog -sv tb/package.sv tb/Interface.sv RTL/Memory_DUT.sv tb/top.sv
vsim -c -voptargs=+acc top
add wave *
run -all
quit -f
