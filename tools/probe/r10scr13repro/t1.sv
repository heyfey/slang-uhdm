// r10scr13 t1 — § connExprBindsNet.
// A module-scope `logic` declaration lands in BOTH the netlist's nets and its
// variables.  Which copy an instance CONNECTION's ref binds is the question:
// Scr1's scr1_top_tb_axi measures 58 in-expression operands ALL binding the
// NET while every bare-ref high_conn binds the VAR.  This file puts the same
// signals in both positions.
module sub #(parameter int W = 8) (
    input  logic [W-1:0] a,
    input  logic [3:0]   b,
    input  logic [3:0]   c,
    input  logic         d,
    input  logic [1:0]   e,
    input  logic [3:0]   f
);
endmodule

module top;
logic [3:0] x;
logic [3:0] y;
logic [3:0] z;
logic [3:0] w;
logic [3:0] v;
logic [3:0] u;
logic [3:0] t;

// a: concatenation      -> operands x, y
// b: bare ref           -> z
// c: unary operation    -> w
// d: bit-select         -> v[2]
// e: part-select        -> u[3:2]
// f: ternary            -> t / z
sub i0 (
    .a ({x, y}),
    .b (z),
    .c (~w),
    .d (v[2]),
    .e (u[3:2]),
    .f (x ? t : z)
);
endmodule
