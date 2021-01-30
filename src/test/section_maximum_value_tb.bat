@echo off
iverilog ../section_maximum_value.v section_maximum_value_tb.v
if not errorlevel 1 (
	vvp a.out
	del a.out
)
