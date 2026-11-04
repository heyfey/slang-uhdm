// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, input [1:0] s, output [3:0] y);
  wire [3:0][3:0] v = b;
  assign y = v[s][('h3)];
endmodule
module top(input [15:0] b, input [1:0] s, output [3:0] y);
  sub u(.b(b), .s(s), .y(y));
endmodule
