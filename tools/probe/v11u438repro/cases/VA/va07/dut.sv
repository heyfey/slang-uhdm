// § caPlainLhsUnsizedClone438
module sub(input [3:0] i, output [3:0] y);
  logic [3:0] mem [0:3];
  assign mem[0] = i;
  assign y = mem['h1];
endmodule
module top(input [3:0] i, output [3:0] y);
  sub u(.i(i), .y(y));
endmodule
