@echo off
iverilog ../pcm_to_indicator_position.v pcm_to_indicator_position_tb.v
if not errorlevel 1 (
	vvp a.out
	del a.out
)
