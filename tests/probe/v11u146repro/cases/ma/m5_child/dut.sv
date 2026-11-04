// § modArrayBoundRefArrayPath146
module sub(input i, output o); assign o = i; endmodule
module mid #(parameter M = 2) (input [M-1:0] a, output [M-1:0] b);
  sub s[M-1:0] (.i(a), .o(b));
endmodule
module top(input [2:0] a, output [2:0] b);
  mid #(.M(3)) m(.a(a), .b(b));
endmodule
