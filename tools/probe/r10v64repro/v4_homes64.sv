// r10v64 ARM 4 — HOME MATRIX: module body / gen-if / gen-for / gen-if inside
// gen-for / nested gen-if / interface body / interface gen-scope, plus the
// same read from an always_comb (NOT a cont_assign) and from an initial.
// MEASUREMENT ONLY.
interface ifcV4 #(parameter int unsigned P = 4) (input logic c);
  logic [3:0] w0, w1, w2;
  localparam int unsigned W = 4;
  assign w0 = c ? P : P;                  // interface BODY cont_assign
  if (P != 0) begin : g_if
    wire [3:0] q0, q1;
    assign q0 = c ? P : P;                // interface GEN-IF cont_assign
    assign q1 = W'(P);
  end
  for (genvar i = 0; i < 2; i++) begin : g_for
    wire [3:0] r0;
    assign r0 = c ? P : P;                // interface GEN-FOR cont_assign
  end
  assign w1 = W'(P);
  assign w2 = P + 1;
endinterface

module subV4 #(parameter int unsigned P = 4)
  (input logic c, input logic [7:0] n, output logic [3:0] y);
  localparam int unsigned W = 4;
  logic [3:0] m0, m1, m2, m3, m4, m5;
  assign m0 = c ? P : P;                  // module BODY
  if (P != 0) begin : g_if
    wire [3:0] q0, q1;
    assign q0 = c ? P : P;                // GEN-IF
    assign q1 = W'(P);
    if (P > 1) begin : g_if2
      wire [3:0] s0;
      assign s0 = c ? P : P;              // NESTED GEN-IF
    end
  end
  for (genvar i = 0; i < 2; i++) begin : g_for
    wire [3:0] r0, r1;
    assign r0 = c ? P : P;                // GEN-FOR
    assign r1 = W'(P);
    if (P != 0) begin : g_fif
      wire [3:0] t0;
      assign t0 = c ? P : P;              // GEN-IF INSIDE GEN-FOR
    end
  end
  always_comb m1 = c ? P[3:0] : P[3:0];   // always_comb (not a cont_assign)
  initial     m2 = P[3:0];                // initial
  assign m3 = W'(P);
  assign m4 = P + 1;
  assign m5 = n[P];
  assign y = m0 ^ m1 ^ m2 ^ m3 ^ m4 ^ {3'b0, m5[0]};
endmodule

module topV4(input logic c, input logic [7:0] n);
  localparam int       SI = 1 * 2;
  localparam bit [3:0] SH = 4'h2;
  localparam bit [3:0] SB = 4'b0010;
  wire [3:0] y1, y2, y3, y4;
  subV4 #(.P(2))  i_dec (c, n, y1);
  subV4 #(.P(SH)) i_hex (c, n, y2);
  subV4 #(.P(SB)) i_bin (c, n, y3);
  subV4 #(.P(SI)) i_exp (c, n, y4);
  ifcV4 #(.P(2))  if_dec (c);
  ifcV4 #(.P(SH)) if_hex (c);
  ifcV4 #(.P(SB)) if_bin (c);
endmodule
