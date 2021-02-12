@echo off
iverilog ^
    ../audio_level_meter.v ^
    ../dual_clock_buffer/dual_clock_buffer.v ^
    ../dataflow_branch.v ^
    ../audio_level_meter_channel.v ^
    ../section_min_max.v ^
    ../section_min_max_buffer.v ^
    ../single_port_ram.v ^
    ../pcm_to_position.v ^
    ../position_to_array.v ^
    ../dataflow_join.v ^
    ../stp16cpc26.v ^
    audio_level_meter_tb.v
if not errorlevel 1 (
	vvp a.out
	del a.out
)
