// § modArrayBoundRefArrayPath146
module sub(input i, output o); assign o = i; endmodule
module top #(parameter N = 3) (input [N-1:0] a, output [N-1:0] b);
  sub u[0:N-1] (.i(a), .o(b));
endmodule
