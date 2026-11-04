// § ppOutputLine166 § ppOutputCol166
`define INST(n, TT) \
  sub #(.T(TT)) \
    n ();
module sub #(parameter type T = logic) ();
  T v;
endmodule
module top;
  `INST(b, logic [7:0])
  sub #(.T(logic [3:0])) a ();
endmodule
