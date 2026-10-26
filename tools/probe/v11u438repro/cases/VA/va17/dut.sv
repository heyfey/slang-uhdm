// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, input [3:0] i, output [1:0] y);
  assign y = b[i +: 'h2];
endmodule
module top(input [15:0] b, input [3:0] i, output [1:0] y);
  sub u(.b(b), .i(i), .y(y));
endmodule
