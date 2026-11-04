// § genNdaUnsizedFreshLhs438
module sub(input [15:0] b, output [1:0] y);
  for (genvar i = 0; i < 2; i++) begin : g
    wire [1:0] w = b[i*2 +: 'h2];
    assign y[i] = w[0];
  end
endmodule
module top(input [15:0] b, output [1:0] y);
  sub u(.b(b), .y(y));
endmodule
