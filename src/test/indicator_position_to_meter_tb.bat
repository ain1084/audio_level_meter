@echo off
iverilog ../indicator_position_to_meter.v indicator_position_to_meter_tb.v
if not errorlevel 1 (
	vvp a.out
	del a.out
)
