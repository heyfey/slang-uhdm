// r11v97 VERIFIER arm k8 — THE WIDENED NAME GUARD'S OWN CONTROL, ON A SHAPE
// THE IMPLEMENTER'S CLAIM EXCLUDES.  § chainStoreChecksTheInitializer97's
// § block says "an OVERRIDDEN parameter and a defaulted port still fail BOTH
// tests".  A DEFAULTED PORT PARAMETER WHOSE DEFAULT IS ITSELF A DIGIT-LAW
// EXPRESSION fails the OLD test and PASSES the new one — slang's evaluation of
// the default IS the store.  This arm holds that shape, at the module home and
// at the package home, defaulted and overridden, so the widening's real
// boundary is measured rather than asserted.
package k8p;
  localparam int U1   = '1 * 2;
  localparam int U1C  = U1 - 0;
endpackage
module k8_sub #(
    parameter int SP = '1 * 2,          // a DIGIT-LAW default
    parameter int SQ = 4'd12 - 0,       // r11u76's based leaf as a default
    parameter int SR = 2 * 3            // the plain control
) (output logic [31:0] q);
  localparam int SPC = SP - 0;          // the chain through the PORT parameter
  localparam int SQC = SQ - 0;
  localparam int SRC = SR - 0;
  assign q = SPC + SQC + SRC;
endmodule
module k8_portdf94v (output logic [63:0] o);
  localparam int ML  = '1 * 2;          // a MODULE-local digit-law parameter
  localparam int MLC = ML - 0;          // and its chain
  wire [31:0] q0, q1;
  k8_sub u0 (.q(q0));                            // every default
  k8_sub #(.SP(5), .SQ(6), .SR(7)) u1 (.q(q1));  // every one OVERRIDDEN
  wire signed [31:0] wU1   = k8p::U1;
  wire signed [31:0] wU1C  = k8p::U1C;
  wire signed [31:0] wML   = ML;
  wire signed [31:0] wMLC  = MLC;
  assign o = {q0, q1} ^ {wU1, wU1C} ^ {wML, wMLC};
endmodule
