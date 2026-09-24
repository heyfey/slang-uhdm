// r11v96 VERIFIER arm v6 — IS THE MINT A PACKAGE FACT?  LAW A sits in the
// PACKAGE-parameter branch of `emitExpr`.  This arm reads the same three
// operators out of a MODULE localparam, a parameter PORT, an overridden
// parameter and a `$unit` file-local one, to see what golden writes there and
// whether anything moved.
package v6p;
  localparam int PMUL = 2 * 3;
endpackage
module v6_sub #(parameter int SP = 4 * 5) (output logic [31:0] q);
  wire signed [31:0] wSP = SP;
  assign q = wSP;
endmodule
module v6_modhome96v (output logic [63:0] o);
  localparam int MMUL = 2 * 3;
  localparam int MDIV = 6 / 2;
  localparam int MMOD = 7 % 4;
  localparam int MSUB = 8 - 1;
  wire signed [31:0] wMMUL = MMUL;
  wire signed [31:0] wMDIV = MDIV;
  wire signed [31:0] wMMOD = MMOD;
  wire signed [31:0] wMSUB = MSUB;
  wire signed [31:0] wPMUL = v6p::PMUL;
  wire [31:0] q1, q2;
  v6_sub u1 (.q(q1));
  v6_sub #(.SP(6 * 7)) u2 (.q(q2));
  assign o = {wMMUL, wMDIV} ^ {wMMOD, wMSUB} ^ {wPMUL, wMMUL} ^ {q1, q2};
endmodule
