// § caPlainLhsUnsizedClone438
module sub(input [3:0] i, output y);
  logic [3:0] mem [0:3];
  assign mem[1] = i;
  assign y = mem['h1]['h2];
endmodule
module top(input [3:0] i, output y);
  sub u(.i(i), .y(y));
endmodule
