// § refSignSrcSurelogSigned264v
module sub #(parameter A = 5, parameter W = 4'd2) (output logic [31:0] o);
  localparam int B = A;
  localparam C = A;
  localparam int D = W;
  localparam E = -2;
  localparam int F = E;
  assign o = B + C + D + F;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
