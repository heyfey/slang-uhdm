// § paramIdxPartSelWholeSpan131
module sub #(parameter int S = 0, parameter logic [15:0] V = 16'h1234, parameter logic [3:0] N = V[S +: 4]) ();
endmodule
module top ();
  sub #(.S(4)) u();
endmodule
