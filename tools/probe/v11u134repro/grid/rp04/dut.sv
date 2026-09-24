// § pkgTsRefObjChainName134
package p;
  parameter int N = 4;
  typedef logic [N-1:0] n_t;
  typedef n_t [1:0] nn_t;
endpackage
module top(input logic [7:0] i, output logic [3:0] o);
  p::nn_t s;
  assign s = i;
  assign o = s[1];
endmodule
