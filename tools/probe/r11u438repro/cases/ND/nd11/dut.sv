// § genNdaUnsizedFreshLhs438 (control: a sized index)
module sub(input [15:0] b, output [1:0] y);
  for (genvar i = 0; i < 2; i++) begin : g
    wire w = b[i];
    assign y[i] = w;
  end
endmodule
module top(input [15:0] b, output [1:0] y);
  sub u(.b(b), .y(y));
endmodule
