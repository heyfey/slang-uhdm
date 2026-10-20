// § varInitUintMask414
module sub #(parameter W = 2) ();
  logic [W-1:0] a = 7;
endmodule
module top;
  sub #(.W(3)) u1();
  sub u2();
endmodule
