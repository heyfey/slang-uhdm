// § genNdaUnsizedFreshLhs438
module sub(input [3:0] i, output [1:0] y);
  logic [3:0] mem [0:3];
  assign mem[1] = i;
  for (genvar k = 0; k < 2; k++) begin : g
    wire w = mem['h1][k];
    assign y[k] = w;
  end
endmodule
module top(input [3:0] i, output [1:0] y);
  sub u(.i(i), .y(y));
endmodule
