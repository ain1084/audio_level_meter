@echo off
iverilog ../position_to_array.v position_to_array_tb.v
if not errorlevel 1 (
	vvp a.out
	del a.out
)
