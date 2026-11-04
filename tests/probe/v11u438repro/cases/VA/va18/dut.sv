// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output [3:0] y);
  assign y = b['h7:'h4];
endmodule
module top(input [15:0] b, output [3:0] y);
  sub u0(.b(b), .y(y));
  sub u1(.b(b), .y());
endmodule
