// § pkgTsRefObjChainName134
// case c03: a package typedef over a package typedef, the inner range references a package parameter
package p;
  parameter int N = 3;
  typedef logic [N-1:0] in_t;
  typedef in_t [1:0] out_t;
  parameter out_t P = '1;
endpackage
module top(output logic [5:0] o);
  assign o = p::P;
endmodule
