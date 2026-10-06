// § elabParamRefSignedTsUnlocated264
module sub #(parameter logic [3:0] U = 4'd3) (output logic [31:0] o);
  localparam int A = U + 1;
  localparam int B = A;
  localparam int C = U;
  localparam int D = C;
  localparam int E = {U, U};
  localparam int F = E;
  assign o = B + D + F;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
