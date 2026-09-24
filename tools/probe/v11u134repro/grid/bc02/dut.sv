// § defNetScopedPkgVecTdShares134
package p;
  typedef logic [3:0] n_t;
endpackage
module top(input logic [3:0] i, output logic [3:0] o);
  wire p::n_t a = i;
  p::n_t b;
  p::n_t c = 4'd7;
  assign b = a;
  assign o = b ^ c;
endmodule
