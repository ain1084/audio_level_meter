@echo off
iverilog ../section_difference.v section_difference_tb.v
if not errorlevel 1 (
	vvp a.out
	del a.out
)
