// § ovUntypedTsDeclWidth427
module sub #(parameter A = 1'b0, parameter B = 4'b0, parameter F = 8'hFF)(input a, output o);
  assign o = a ^ A[0] ^ B[0] ^ F[0];
endmodule
module top(input a, output [2:0] o);
  sub #(4'b1001, 16'hABCD, 2'b11) u1(.a(a), .o(o[0]));
  sub #(.A(1'b1), .B(4'b1), .F(8'h1)) u2(.a(a), .o(o[1]));
  sub u3(.a(a), .o(o[2]));
  defparam u3.A = 4'b1001;
endmodule
