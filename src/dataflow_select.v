`default_nettype none

// Dataflow select for valid and ready handshake.
// This implementation was based on the following article by @ikwzm.
// https://qiita.com/ikwzm/items/e4ec2290e08326f5e06c

module dataflow_select #(parameter width = 8)(
    input wire [1:0] i_valid,
    output wire [1:0] i_ready,
    input wire select,
    output wire o_valid,
    input wire o_ready);

    assign o_valid = i_valid[select];
    assign i_ready = { o_ready && select == 1'b1, o_ready && select == 1'b0 };

endmodule
