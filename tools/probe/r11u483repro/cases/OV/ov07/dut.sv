// § clsScopedOvRhsRefObj483
class S;
  localparam w = 16;
endclass
module sub #(A = 8) ();
  logic [A-1:0] d;
endmodule
module top;
  sub #(.A(S::w)) u();
endmodule
