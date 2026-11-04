// § refSignSrcSurelogSigned264v
module sub #(parameter A = 5, parameter shortint S = 2, parameter byte Y = 1) (output logic [31:0] o);
  localparam int B = A;
  localparam int C = S;
  localparam int D = Y;
  assign o = '0;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
