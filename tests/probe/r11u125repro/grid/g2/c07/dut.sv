// § spanCopyCarriesFile125
package pk;
  parameter int W = 64;
  typedef logic [W-1:0] w_t;
  typedef struct packed { w_t a; w_t b; } s_t;
  localparam s_t D = 128'h0123456789abcdef_fedcba9876543210;
endpackage
module sub #(parameter int N = 1, parameter logic [N-1:0] R = 0) ();
endmodule
module top();
  import pk::*;
  parameter s_t P = D;
  sub #(.N(W), .R(P.b)) u();
endmodule
