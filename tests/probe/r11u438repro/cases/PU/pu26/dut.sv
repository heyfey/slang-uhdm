// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output [7:0] y);
  assign y = {b['h1], b[6:0]};
endmodule
module top(input [15:0] b, output [7:0] y);
  sub u(.b(b), .y(y));
endmodule
