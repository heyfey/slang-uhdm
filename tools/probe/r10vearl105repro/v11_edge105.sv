// r10v105 v11 — THE ARM'S OWN EDGES: the LHS gate `(!inLhs || inPsBound)`, a
// DEFPARAM override, a HIERARCHICAL Rhs out of the loop body, an UNPACKED-array
// parameter, and a parameter read in a NET RANGE inside the loop body (not a
// cont_assign at all).
module v11_leaf105 (input logic [31:0] sig, output logic [63:0] z);
  localparam int         B   = 4;
  localparam logic [3:0] R4  = {2{2'b01}};
  logic [63:0] arr;
  logic [63:0] brr;
  for (genvar i = 0; i < 2; i++) begin : gen_e
    logic [B-1:0] nr;                 // a NET RANGE read, not a cont_assign
    logic [63:0] e0, e1;
    assign arr[B]      = sig[0];      // an LHS BIT-SELECT index  (inLhs, blocked)
    assign brr[B +: 2] = sig[1:0];    // an LHS INDEXED-PART-SELECT base (inPsBound)
    assign e0 = nr[0] ^ sig;
    assign e1 = R4 ^ sig;             // the law's own window beside them
  end
  assign z = arr ^ brr;
endmodule

module v11_hier105 (input logic [31:0] sig, output logic [63:0] z);
  localparam int H = 3;
  logic [63:0] hz;
  for (genvar i = 0; i < 2; i++) begin : gen_h
    logic [63:0] h0;
    assign h0 = H ^ sig;
  end
  assign hz = gen_h[0].h0;
  assign z  = hz;
endmodule

module v11_edge105 (input logic [31:0] sig, output logic [63:0] z);
  logic [63:0] za, zb;
  v11_leaf105 u_leaf (.sig(sig), .z(za));
  v11_hier105 u_hier (.sig(sig), .z(zb));
  assign z = za ^ zb;
endmodule
