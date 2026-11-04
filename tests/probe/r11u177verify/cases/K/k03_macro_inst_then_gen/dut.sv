// § ppOutputLine166 § ppOutputCol166
`define INST(n, TT) \
  sub #(.T(TT)) \
    n ();
module sub #(parameter type T = logic) ();
  T v;
endmodule
module top;
  `INST(b, logic [7:0])
  if (1) begin : g
    sub #(.T(logic [5:0])) c ();
  end
endmodule
