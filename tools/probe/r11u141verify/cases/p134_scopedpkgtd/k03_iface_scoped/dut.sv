// § defNetScopedPkgVecTdShares134
// case k03: an interface signal typed by a package-scoped vector typedef, with an initializer
package p;
  typedef logic [5:0] w_t;
endpackage
interface ifc;
  p::w_t s = 6'd7;
endinterface
module top(output logic [5:0] o);
  ifc u();
  assign o = u.s;
endmodule
