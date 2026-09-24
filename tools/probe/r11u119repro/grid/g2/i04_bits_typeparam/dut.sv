module shift_reg #(parameter type dtype = logic) (
    input  dtype d_i,
    output dtype d_o
);
    assign d_o = d_i;
endmodule
module top #(parameter int W = 5) (
    input  logic [7:0] a,
    input  logic [W-1:0] b,
    output logic [8+W-1:0] o
);
    shift_reg #(.dtype(logic [$bits(a) + $bits(b) - 1:0])) u (
        .d_i({a, b}),
        .d_o(o)
    );
endmodule
