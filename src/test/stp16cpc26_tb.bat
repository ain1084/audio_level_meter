@echo off
iverilog ../stp16cpc26.v stp16cpc26_tb.v
if not errorlevel 1 (
    vvp a.out
    del a.out
)
