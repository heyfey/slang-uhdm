// § clsScopedRangeKept474 (decode grid)
package p;
  class S;
    localparam w = 16;
  endclass
endpackage
interface ifc #(A = 8) ();
  logic [A-1:0] d;
endinterface
module top;
  import p::*;
  ifc #(.A(S::w)) u();
endmodule
