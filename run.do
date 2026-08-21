vlib work
vlog -sv package.sv Interface.sv Memory_DUT.sv top.sv
vsim -c -voptargs=+acc top
add wave *
run -all
quit -f
