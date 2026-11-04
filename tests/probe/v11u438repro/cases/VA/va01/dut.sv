// § caPlainLhsUnsizedClone438
module sub #(parameter P = 0) (input [15:0] b, output y);
  assign y = b['h1 + P];
endmodule
module top(input [15:0] b, output y, z);
  sub #(.P(2)) u(.b(b), .y(y));
  sub #(.P(5)) v(.b(b), .y(z));
endmodule
