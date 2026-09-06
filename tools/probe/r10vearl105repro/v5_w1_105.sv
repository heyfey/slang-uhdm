// r10v105 v5 — WIDTH-1 and narrow parameters (r10earl55's mints must stay) and
// a parameter read in BOTH a substituting and a NON-substituting position in
// ONE scope, the pair as its own arm.
module v5_leaf105 #(parameter int W1 = 1) (input logic [31:0] sig, output logic [63:0] z);
  localparam bit           B1 = 1'b1;
  localparam logic         L1 = 1'b0;
  localparam int           ONE = 1;
  localparam logic [0:0]   V1 = 1'b1;
  for (genvar i = 0; i < 2; i++) begin : gen_w
    logic [63:0] s0,s1,s2,s3,s4,s5;
    assign s0 = ONE ^ sig;                 // substituting position
    assign s1 = $clog2(ONE) ^ sig;         // a SYSTEM-CALL argument: keeps the ref
    assign s2 = B1 ^ sig;
    assign s3 = L1 ^ sig;
    assign s4 = V1 ^ sig;
    assign s5 = W1 ^ sig;
  end
  assign z = 64'b0;
endmodule

module v5_w1_105 (input logic [31:0] sig, output logic [63:0] z);
  logic [63:0] zc;
  v5_leaf105 #(.W1(1)) u_leaf (.sig(sig), .z(zc));
  assign z = zc;
endmodule
