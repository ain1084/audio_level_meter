`default_nettype none

// Fork valid-and-ready
// This implementation was based on the following article by @ikwzm.
// https://qiita.com/ikwzm/items/e4ec2290e08326f5e06c

module fork_valid_ready(
    input wire i_valid,
    output wire i_ready,
    output wire [1:0] o_valid,
    input wire [1:0] o_ready
);

    assign i_ready = o_ready[0] && o_ready[1];
    assign o_valid = { i_valid && o_ready[1], i_valid && o_ready[0] };

endmodule