// § pkgTsRefObjChainName134
// case c02: a package parameter of a package vector typedef whose range references a package parameter
package p;
  parameter int N = 4;
  typedef logic [N-1:0] v_t;
  parameter v_t INIT = 4'hA;
endpackage
module top(output logic [3:0] o);
  assign o = p::INIT;
endmodule
