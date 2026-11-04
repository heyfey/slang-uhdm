// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, input [15:0] c, output [15:0] y);
  wire sel;
  assign sel = b['h0];
  assign y = sel ? b : c;
endmodule
module top(input [15:0] b, c, output [15:0] y);
  sub u(.b(b), .c(c), .y(y));
endmodule
