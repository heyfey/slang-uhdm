// § clsDynRealArrPropElem462
package p;
  class C;
    real d[];
    rand int k;
  endclass
endpackage
module top;
  import p::*;
  initial begin C c; c = new; end
endmodule
