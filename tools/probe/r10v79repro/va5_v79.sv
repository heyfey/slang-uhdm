// r10v79 adversarial arm 5 — the RECURSIVE NAME-LEAF walk: cross-scope
// overrides, SHADOWED names, and chained parameter initializers.  dimRedCt79
// resolves the leaf in the PARAMETER'S OWN scope, but the override expression
// was written in the PARENT's — where those two disagree, the encoding can be
// read off the wrong symbol.
module child5 #(
  parameter int unsigned P = 4,
  parameter int unsigned Q = 4,
  parameter int unsigned R = 4
) (input logic clk);
  // SH exists in BOTH the parent and here, with DIFFERENT encodings.
  localparam int unsigned SH = 9;
  logic [7:0] c_p [P+1];
  logic [7:0] c_q [Q+1];
  logic [7:0] c_r [R+1];
  logic [7:0] c_sh [SH+1];
endmodule

module mid5 #(parameter int unsigned N = 4) (input logic clk);
  localparam int      SH = N * 2;     // INT-flavoured, SHADOWED in child5
  localparam int      LQ = N * 3;     // INT-flavoured
  localparam int unsigned LU = N + 1; // UINT-flavoured
  // .P(LQ) -> child5's P initializer is the NAME `LQ`, unresolvable in child5
  // .Q(SH) -> child5's Q initializer is `SH`, which RESOLVES IN child5 to a
  //           DIFFERENT symbol (localparam int unsigned SH = 9)
  // .R(LU) -> the agreeing control
  child5 #(.P(LQ), .Q(SH), .R(LU)) u_c (.clk(clk));
endmodule

module topv5;
  logic clk;
  mid5 #(.N(5)) u_a (.clk(clk));
  mid5 #(.N(7)) u_b (.clk(clk));
endmodule
