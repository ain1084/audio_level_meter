`default_nettype none

// Dataflow fork for valid and ready handshake.
// This implementation was based on the following article by @ikwzm.
// https://qiita.com/ikwzm/items/e4ec2290e08326f5e06c

module dataflow_fork(
    input wire i_valid,
    output wire i_ready,
    output wire [1:0] o_valid,
    input wire [1:0] o_ready);

    assign i_ready = &o_ready;
    assign o_valid = { i_valid && o_ready[0], i_valid && o_ready[1] };

endmodule
