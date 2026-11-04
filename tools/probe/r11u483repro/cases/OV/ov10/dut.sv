// § clsScopedOvRhsRefObj483
module sub #(A = 8) ();
  logic [A-1:0] d;
endmodule
module top;
  class S;
    localparam w = 16;
  endclass
  sub #(.A(S::w)) u();
endmodule
