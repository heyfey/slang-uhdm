// r10scr13 t2 — § connExprBindsNet, discriminator hunt.
// t1 showed concat/unary operands binding the NET copy while the TERNARY's
// CONDITION operand bound the VAR.  Every name below is used EXACTLY ONCE so
// order-of-use cannot confound the reading.
module sub (
    input logic [3:0] p1, input logic [3:0] p2, input logic [3:0] p3,
    input logic [3:0] p4, input logic [3:0] p5, input logic [3:0] p6,
    input logic [3:0] p7, input logic [3:0] p8
);
endmodule

module top;
logic [3:0] a1, a2;          // binary and
logic [3:0] b1, b2, b3;      // ternary, all three operands fresh
logic [3:0] c1, c2;          // concat
logic [3:0] d1, d2;          // add
logic [3:0] e1;              // unary
logic [3:0] f1;              // bare ref
logic [3:0] g1, g2;          // nested: (g1 & g2) inside a concat
logic [3:0] h1;              // inside a system function call

sub i0 (
    .p1 (a1 & a2),
    .p2 (b1 ? b2 : b3),
    .p3 ({c1, c2}),
    .p4 (d1 + d2),
    .p5 (~e1),
    .p6 (f1),
    .p7 ({(g1 & g2)}),
    .p8 ($signed(h1))
);
endmodule
