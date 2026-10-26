// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, input [3:0] s, output y);
  logic [15:0] v;
  assign v = b;
  assign y = v[s + 'h1];
endmodule
module top(input [15:0] b, input [3:0] s, output y);
  sub u(.b(b), .s(s), .y(y));
endmodule
