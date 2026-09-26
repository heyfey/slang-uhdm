// § castRhsClonePerInst176
module sub #(parameter Y = 3) ();
  assign a = int'(Y + 1);
endmodule
module top;
  sub u_d ();
  sub #(.Y(7)) u_7 ();
endmodule
