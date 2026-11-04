// § elabParamRefSignedTsUnlocated264
module sub (output logic [31:0] o);
  localparam int A = 6;
  localparam int N = -4;
  localparam int K = (A > 2) ? N : A;
  assign o = '0;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
