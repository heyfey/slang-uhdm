// § castRhsClonePerInst176
module sub #(parameter Y = 3) ();
  assign a = int'(Y);
endmodule
module top;
  for (genvar i = 0; i < 2; i++) begin : g
    sub #(.Y(i)) u ();
  end
endmodule
