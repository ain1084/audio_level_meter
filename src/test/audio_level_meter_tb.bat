@echo off
iverilog ^
    ../section_maximum_value.v ^
    ../indicator_position_to_meter.v ^
    ../pcm_to_indicator_position.v ^
    ../dual_clock_buffer.v ^
    ../serial_decoder.v ^
    ../audio_level_meter.v ^
    ../stp16cpc26.v ^
    audio_level_meter_tb.v
if not errorlevel 1 (
	vvp a.out
	del a.out
)
