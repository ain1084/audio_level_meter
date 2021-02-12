`default_nettype none

// Dataflow outlet switch for valid and ready handshake.
// This implementation was based on the following article by @ikwzm.
// https://qiita.com/ikwzm/items/e4ec2290e08326f5e06c

module dataflow_branch(
    input wire i_valid,
    output wire i_ready,
    input wire select,
    output wire [1:0] o_valid,
    input wire [1:0] o_ready);

    assign i_ready = o_ready[select];
    assign o_valid = { i_valid && select == 1'b1, i_valid && select == 1'b0 };

endmodule
