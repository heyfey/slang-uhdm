// § clsDynRealArrPropElem462
package p;
  class C;
    real r[] = '{1.5, 2.5};
    real q[$:3];
    shortreal s[int];
  endclass
endpackage
module top;
  import p::*;
  C c;
endmodule
