// § modArrayBoundRefArrayPath146
module sub(input i, output o); assign o = i; endmodule
module top #(parameter N = 4) (input [N-1:0] a, output [N-1:0] b);
  sub u[$clog2(N)+1:0] (.i(a), .o(b));
endmodule
