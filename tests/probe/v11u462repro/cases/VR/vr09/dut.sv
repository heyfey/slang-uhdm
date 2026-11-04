// § clsDynRealArrPropElem462
package p;
  typedef real r_t;
endpackage
class C;
  p::r_t d[];
  real dd[][];
endclass
module top;
  initial begin C c; c = new; end
endmodule
