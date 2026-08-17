// g1: RESIDUE PROBE -- an EXPLICIT CAST operand.  UHDM builds a vpiCastOp
// OPERATION there, which the pre-scan steps over; our classifier answers Stop
// (slang's ExpressionKind::Conversion is not one of the operation forms
// srlgOperandsOf49 models), so we UNDER-fire.  This arm measures the cost.
module g1_earl49 #(
  parameter int           W  = 32,
  parameter logic [W-1:0] G1 = 'h1,   // W'(G1) & G2  -- cast operand FIRST
  parameter logic [W-1:0] G2 = 'h2,   // ...and a bare name SECOND
  parameter logic [W-1:0] G3 = 'h3    // W'(G3) & n   -- cast then a net
) (
  input  logic [W-1:0] n,
  output logic [W-1:0] o1, o3
);
  assign o1 = W'(G1) & G2;
  assign o3 = W'(G3) & n;
endmodule
