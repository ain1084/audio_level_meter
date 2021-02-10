`default_nettype none

module single_port_ram #(parameter width = 16, size = 256)(
    input wire clk,
    input wire [$clog2(size)-1:0] ad,
    output reg [width-1:0] rd,
    input wire we,
    input wire [width-1:0] wd);

    reg [width-1:0] mem [size-1:0];
    always @(posedge clk) begin
        if (we)
            mem[ad] <= wd;
        rd <= mem[ad];
    end
endmodule
