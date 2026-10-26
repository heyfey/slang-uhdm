// § ndaUnsizedRhsFreshLhs438
module sub(input [3:0] i, output [3:0] y);
  logic [3:0] mem [0:3];
  assign mem[2] = i;
  wire [3:0] w = mem['h2];
  assign y = w;
endmodule
module top(input [3:0] i, output [3:0] y);
  sub u(.i(i), .y(y));
endmodule
