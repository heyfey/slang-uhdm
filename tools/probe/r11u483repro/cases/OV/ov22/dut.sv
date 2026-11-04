// § clsScopedOvRhsRefObj483
package p;
  class S;
    localparam w = 16;
  endclass
endpackage
module sub #(A = 8) ();
  logic [A-1:0] d;
endmodule
module top;
  sub #(.A(p::S::w)) u();
endmodule
