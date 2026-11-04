// § genNdaUnsizedFreshLhs438
module sub(input [15:0] b, output y);
  for (genvar i = 0; i < 1; i++) begin : g
    wire [3:0] l = b[7:4];
    wire w = l['h1];
    assign y = w;
  end
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
