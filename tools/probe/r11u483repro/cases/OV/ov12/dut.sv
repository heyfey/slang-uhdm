// § clsScopedOvRhsRefObj483
package p;
  class S;
    localparam w = 16;
  endclass
endpackage
module leaf #(A = 8) ();
  logic [A-1:0] d;
endmodule
module mid;
  import p::*;
  leaf #(.A(S::w)) l();
endmodule
module top;
  mid m1();
  mid m2();
endmodule
