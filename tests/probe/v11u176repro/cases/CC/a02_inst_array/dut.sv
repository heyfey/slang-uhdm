// § castRhsClonePerInst176
module sub #(parameter Y = 3) ();
  assign a = int'(Y);
endmodule
module top;
  sub #(.Y(5)) u [1:0] ();
endmodule
