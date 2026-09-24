// r10v105 v7 — THE SHARPEST PROBE AT THE OLD WINDOWS.  The new full-CLONE arm
// runs in EVERY window, not only the new one, and it preempts the decimal
// mint whenever the source `param_assign` Rhs's typespec ref is ALREADY BOUND
// and its actual is an int_typespec.  r10earl104's replication fold mints
// exactly such a typespec, and its encoding (BIN, narrow) is NOT the decimal
// the mint would build — so a COPY and a MINT are distinguishable here at the
// SELECT positions that pristine already folded.
module v7_leaf105 (input logic [31:0] sig, output logic [63:0] z);
  localparam int          NP = 4;
  localparam logic [3:0]  R4 = {2{2'b01}};        // = 4'b0101, a REPLICATION fold
  localparam logic [NP-1:0] RN = {NP{1'b1}};      // = 4'b1111, ditto
  for (genvar i = 0; i < 2; i++) begin : gen_r
    logic [63:0] y0,y1,y2,y3,y4,y5,y6;
    assign y0 = R4 ^ sig;                 // PLAIN         (the NEW window)
    assign y1 = sig[R4];                  // bit-select INDEX   (an OLD window)
    assign y2 = sig[R4 +: 2];             // ips BASE           (an OLD window)
    assign y3 = sig[R4+1 : R4];           // part-select BOUNDS (an OLD window)
    assign y4 = sig[R4+i];                // index as an OPERATION (an OLD window)
    assign y5 = {RN{1'b1}} ^ sig;         // a replication COUNT
    assign y6 = (R4 > NP) ? sig : 32'b0;  // a comparison
  end
  assign z = 64'b0;
endmodule

module v7_repl105 (input logic [31:0] sig, output logic [63:0] z);
  // the SAME reads with the SAME parameter shapes in the TOP module, where
  // `genCaLoopParamFold` (not the new flag) is what arms the arm.
  localparam int          TP = 4;
  localparam logic [3:0]  T4 = {2{2'b01}};
  logic [63:0] zc;
  v7_leaf105 u_leaf (.sig(sig), .z(zc));
  for (genvar i = 0; i < 2; i++) begin : gen_t
    logic [63:0] x0,x1,x2,x3,x4;
    assign x0 = T4 ^ sig;
    assign x1 = sig[T4];
    assign x2 = sig[T4 +: 2];
    assign x3 = sig[T4+1 : T4];
    assign x4 = {TP{1'b1}} ^ sig;
  end
  assign z = zc;
endmodule
