// § elabParamRefSignedTsUnlocated264
module sub (output logic [31:0] o);
  localparam int A = 8'd5;
  localparam int B = A;
  localparam int C = 'h10;
  localparam int D = C;
  localparam int E = 32'hFFFF_FFF0;
  localparam int F = E;
  localparam int G = 3'sd3;
  localparam int H = G;
  assign o = B + D + F + H;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
