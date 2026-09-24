// § constCtxCallArgInner131v
module sub #(parameter logic [15:0] A = 16'h00f0, parameter int P = $clog2(A[4 +: 8])) ();
endmodule
module top ();
  sub u();
endmodule
