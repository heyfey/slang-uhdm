// r10earl55 a5 — THE WIDTH-1 BOUNDARY.  a4's table says the CONSUMER decides
// the fold's typespec at width 4 and 15, but at width 1 EVERY consumer gives
// the LOC-LESS int_typespec.  This arm asks where the width-1 rule ENDS:
// non-zero-based single-bit ranges, a wider replicated OPERAND squeezed into
// one bit, `bit`/`reg`, a genuinely SCALAR `logic` (no range at all), a
// multi-dimensional [0:0][0:0], a signed vector, a package, a generate block,
// an interface, a function, and the DEF listing.
package pk5_55;
  parameter int ONE = 1;
  // a PACKAGE never folds a replication in either view (r10c9/b) — fence
  localparam logic [0:0] PKW1 = {1{1'b1}};
endpackage

module a5_earl55(input logic ext);
  e1_55 u_e1 (.o(), .ext(ext));
  e2_55 u_e2 (.o(), .ext(ext));
  e3_55 u_e3 (.o(), .ext(ext));
  e4_55 u_e4 (.o(), .ext(ext));
  e5_55 u_e5 (.o(), .ext(ext));
  e6_55 u_e6 (.o(), .ext(ext));
  e7_55 u_e7 (.o(), .ext(ext));
  e8_55 u_e8 (.o(), .ext(ext));
endmodule

// the witness shape itself (rv_dm SelectableHarts): width from a parameter
module e1_55 #(parameter int NR = 1) (output logic o, input logic ext);
  localparam logic [NR-1:0] S = {NR{1'b1}};
  k5_55 #(.P(S)) u_k (.z(o));
endmodule

// A: [0:0] literal   B: [3:3] non-zero-based single bit
// C: [0:0] with a WIDER operand   D: signed
module e2_55 (output logic o, input logic ext);
  localparam logic [0:0]        A = {1{1'b1}};
  localparam logic [3:3]        B = {1{1'b1}};
  localparam logic [0:0]        C = {1{2'b10}};
  localparam logic signed [0:0] D = {1{1'b1}};
  assign o = ext;
endmodule

// bit / reg / a SCALAR logic with no range at all
module e3_55 (output logic o, input logic ext);
  localparam bit   [0:0] E = {1{1'b1}};
  localparam reg   [0:0] F = {1{1'b1}};
  localparam logic       G = {1{1'b1}};
  assign o = ext;
endmodule

// multi-dimensional single bit, and a 2-bit vector as the near neighbour
module e4_55 (output logic o, input logic ext);
  localparam logic [0:0][0:0] H = {1{1'b1}};
  localparam logic [1:0]      I = {2{1'b1}};
  assign o = ext;
endmodule

// inside a GENERATE block
module e5_55 (output logic o, input logic ext);
  for (genvar g = 0; g < 2; g++) begin : gen_b
    localparam logic [0:0] J = {1{1'b1}};
    wire wj = J[0];
  end
  assign o = ext;
endmodule

// a package-declared single-bit fold read from a module (the package FENCE)
module e6_55 (output logic o, input logic ext);
  localparam logic [0:0] K = pk5_55::PKW1;
  assign o = ext ^ K[0];
endmodule

// a NESTED replication and a replication of a CONCAT at width 1
module e7_55 (output logic o, input logic ext);
  localparam logic [0:0] L = {1{{1{1'b1}}}};
  localparam logic [0:0] M = {1{{1'b1}}};
  assign o = ext;
endmodule

// width-1 folds with each of a4's consumers, to re-confirm on this arm
module e8_55 (output logic o, input logic ext);
  localparam logic [0:0] N = {1{1'b1}};
  localparam logic [0:0] P = {1{1'b1}};
  localparam logic [0:0] Q = {1{1'b1}};
  assign o = N[0] ^ ext;
  wire wq;
  assign wq = Q;
  if (P[0]) begin : g_t wire wp = 1'b1; end else begin : g_f wire wp = 1'b0; end
endmodule

module k5_55 #(parameter P = 0) (output logic z); assign z = |P; endmodule
