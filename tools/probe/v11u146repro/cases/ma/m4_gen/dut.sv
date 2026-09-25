// § modArrayBoundRefArrayPath146
module sub(input i, output o); assign o = i; endmodule
module top #(parameter N = 2) (input [N-1:0] a, output [N-1:0] b);
  generate if (1) begin : g
    sub u[N-1:0] (.i(a), .o(b));
  end endgenerate
endmodule
