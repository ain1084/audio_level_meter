@echo off
iverilog ../section_min_max.v section_min_max_tb.v
if not errorlevel 1 (
	vvp a.out
	del a.out
)
