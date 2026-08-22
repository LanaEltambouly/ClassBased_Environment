vlib work
vlog -sv +cover tb/package.sv tb/Interface.sv RTL/Memory_DUT.sv tb/top.sv
vsim -c -voptargs=+acc -coverage top
add wave *
run -all
coverage report -detail -cvg -directive
coverage report -output coverage_report.txt -detail -cvg -directive
quit -f

