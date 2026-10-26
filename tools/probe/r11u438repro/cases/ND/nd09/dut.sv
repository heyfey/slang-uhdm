// § genNdaUnsizedFreshLhs438
module sub(input [15:0] b, output [7:0] y);
  for (genvar i = 0; i < 2; i++) begin : g
    wire [3:0] w = b['h7:'h4];
    assign y[i*4 +: 4] = w;
  end
endmodule
module top(input [15:0] b, output [7:0] y);
  sub u(.b(b), .y(y));
endmodule
