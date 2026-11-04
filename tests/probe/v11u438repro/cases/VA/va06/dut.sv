// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output signed [1:0] y);
  assign y = $signed(b['h1 +: 2]);
endmodule
module top(input [15:0] b, output signed [1:0] y);
  sub u(.b(b), .y(y));
endmodule
