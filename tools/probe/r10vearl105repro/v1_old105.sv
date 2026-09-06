// r10v105 v1 — the OLD windows of the gen-scope loop fold, in a TOP module.
// Every read below already folded on the PRISTINE binary (genCaLoopParamFold).
// The patch inserts a full-CLONE arm AHEAD of the decimal mint that answers
// these same windows, so a COPY and a MINT must be distinguishable: every
// parameter here is `int`-family (its param_assign Rhs carries an
// int_typespec, which is the clone arm's own trigger) but initialised in a
// NON-DECIMAL base, or signed-negative, or narrower than its declared width.
module v1_old105 (input logic [31:0] sig, output logic [63:0] z);
  localparam int          A = 8;
  localparam int          B = 8'hF0;
  localparam int          C = 6'b101010;
  localparam int signed   D = -3;
  localparam int unsigned E = 8'o17;
  localparam int          F = 32'd5;
  localparam bit signed [7:0]   G = 8'hA5;
  localparam logic signed [7:0] H = 8'b1010_0101;

  for (genvar i = 0; i < 2; i++) begin : gen_o
    logic [63:0] q0,q1,q2,q3,q4,q5,q6,q7,q8,q9,qa,qb;
    assign q0 = B ^ sig;                    // plain binary operand
    assign q1 = B;                          // the LONE Rhs
    assign q2 = {B, C} ^ sig;               // concat operands
    assign q3 = sig[A];                     // a bit-select INDEX
    assign q4 = sig[A +: 2];                // an indexed-part-select BASE
    assign q5 = sig[F+1 : F];               // part-select BOUNDS
    assign q6 = {F{1'b1}} ^ sig;            // a replication COUNT
    assign q7 = (B > C) ? sig : 32'b0;      // a comparison
    assign q8 = ~C ^ sig;                   // a unary operand
    assign q9 = D ^ sig;                    // a SIGNED NEGATIVE int
    assign qa = E ^ G ^ H ^ sig;            // octal + signed vectors
    assign qb = sig[A+i];                   // an index written as an OPERATION
  end
  assign z = 64'b0;
endmodule
