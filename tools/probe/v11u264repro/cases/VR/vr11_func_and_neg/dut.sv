// § elabParamRefSignedTsUnlocated264
module sub (output logic [31:0] o);
  function automatic int f(int x); return x * 2; endfunction
  localparam int A = f(3);
  localparam int B = A;
  localparam int N = -4;
  localparam int M = N;
  localparam int K = (A > 2) ? N : A;
  localparam int J = 1 ? B : 0;
  assign o = B + M + K + J;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
