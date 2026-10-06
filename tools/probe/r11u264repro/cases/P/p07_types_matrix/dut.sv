// § elabParamRefSignedTsUnlocated264
module sub #(parameter int A = 5, parameter logic [3:0] U = 4'd3, parameter integer G = 7) (output logic [31:0] o);
  localparam logic [7:0] T1 = A;
  localparam integer T2 = A;
  localparam byte T3 = A;
  localparam int T4 = U;
  localparam int T5 = G;
  localparam T6 = A;
  localparam logic signed [7:0] S = -3;
  localparam int T7 = S;
  localparam int T8 = (A);
  localparam int T9 = int'(A);
  localparam int T10 = -A;
  localparam int T11 = +A;
  assign o = T1 + T2 + T3 + T4 + T5 + T6 + T7 + T8 + T9 + T10 + T11;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
