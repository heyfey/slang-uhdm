// § xzOvLitKeepsText427
module sub #(parameter P = 4'b0, parameter R = 8'h00)(input a, output o); assign o = a ^ P[0] ^ R[0]; endmodule
module top(input a, output [1:0] o);
  sub u1(.a(a), .o(o[0]));
  defparam u1.P = 4'b10x1;
  sub #(.R(8'b1111_xxxx)) u2(.a(a), .o(o[1]));
endmodule
