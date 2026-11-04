// § pkgTsRefObjChainName134
package p;
  parameter int N = 4;
  typedef logic [N-1:0] n_t;
  parameter n_t P = 4'h3;
  parameter logic [N-1:0] Q = 4'h5;
endpackage
module top(output logic [3:0] o);
  assign o = p::P ^ p::Q;
endmodule
