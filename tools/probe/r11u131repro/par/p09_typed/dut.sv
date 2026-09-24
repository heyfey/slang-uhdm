// § paramFoldParenSpan131
module sub #(parameter int unsigned W = 8, parameter logic [7:0] D = (W+1)) ();
endmodule
module top ();
  sub #(.W(2)) u();
endmodule
