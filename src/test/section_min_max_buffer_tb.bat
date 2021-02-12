@echo off
iverilog ../section_min_max.v ../section_min_max_buffer.v ../single_port_ram.v section_min_max_buffer_tb.v
if not errorlevel 1 (
	vvp a.out
	del a.out
)
