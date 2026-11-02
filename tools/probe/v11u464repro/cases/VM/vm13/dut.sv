// § clsInnerUnsizedAnyElem464 (a package class with a reg vector element)
package p;
  class C;
    reg [7:0] m[2][];
    logic [7:0] n[4][];
  endclass
endpackage
import p::*;
module top;
  initial begin C c; c = new; end
endmodule
