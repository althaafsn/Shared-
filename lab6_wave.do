onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpuTest/allRegs
add wave -noupdate /cpuTest/clk
add wave -noupdate /cpuTest/err
add wave -noupdate /cpuTest/reset
add wave -noupdate /cpuTest/sim_in
add wave -noupdate /cpuTest/sim_load
add wave -noupdate /cpuTest/sim_N
add wave -noupdate /cpuTest/sim_out
add wave -noupdate /cpuTest/sim_s
add wave -noupdate /cpuTest/sim_V
add wave -noupdate /cpuTest/sim_w
add wave -noupdate /cpuTest/sim_Z
add wave -noupdate /cpuTest/stateWait
add wave -noupdate /cpuTest/statusOut
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2153 ps}
