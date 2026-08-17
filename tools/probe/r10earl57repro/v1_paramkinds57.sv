// r10earl57 v1 — THE CAST-TARGET GRID, one row per PARAMETER KIND.
// Every cast operand is a PORT NET so no cast folds away and both the DEF and
// the ELAB listing hold it (k57 is a CHILD instance).
//
// The axes: DECLARATION SITE (parameter port list vs module body), the
// DECLARED DEFAULT (literal vs computed vs another parameter), the TYPE
// KEYWORD (int unsigned / integer / logic[7:0] / bit / none), and whether the
// instantiation OVERRIDES it.
module k57 #(
  parameter  int unsigned PLIT  = 8,
  parameter  int unsigned PDEP  = PLIT + 1,
  localparam int unsigned QLIT  = 5,
  localparam int unsigned QDEP  = (PLIT == 0) ? 1 : PLIT,
  parameter  integer      PINTG = 6,
  parameter               PUNT  = 7,
  parameter  logic [7:0]  PLOG  = 8'd9,
  parameter  bit [5:0]    PBIT  = 6'd10,
  parameter  int unsigned POVR  = 3
) (
  input  logic [31:0] sig,
  output logic [31:0] o1, o2, o3, o4, o5, o6, o7, o8, o9,
  output logic [31:0] o10, o11, o12, o13, o14
);
  localparam int unsigned BLIT = 6;
  localparam int unsigned BDEP = $clog2(PLIT + 1);
  localparam              BUNT = 4;
  localparam int unsigned BREF = PLIT;

  assign o1  = PLIT'(sig);
  assign o2  = PDEP'(sig);
  assign o3  = QLIT'(sig);
  assign o4  = QDEP'(sig);
  assign o5  = PINTG'(sig);
  assign o6  = PUNT'(sig);
  assign o7  = PLOG'(sig);
  assign o8  = PBIT'(sig);
  assign o9  = POVR'(sig);
  assign o10 = BLIT'(sig);
  assign o11 = BDEP'(sig);
  assign o12 = BUNT'(sig);
  assign o13 = BREF'(sig);
  assign o14 = (BLIT+1)'(sig);
endmodule

module top57k (
  input  logic [31:0] s,
  output logic [31:0] a1, a2, a3, a4, a5, a6, a7, a8, a9,
  output logic [31:0] a10, a11, a12, a13, a14
);
  k57 #(.POVR(11)) i_k (
    .sig(s), .o1(a1), .o2(a2), .o3(a3), .o4(a4), .o5(a5), .o6(a6), .o7(a7),
    .o8(a8), .o9(a9), .o10(a10), .o11(a11), .o12(a12), .o13(a13), .o14(a14));
endmodule
