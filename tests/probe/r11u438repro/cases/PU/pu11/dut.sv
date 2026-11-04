// § caPlainLhsUnsizedClone438
module sub(input [3:0][7:0] b, output y);
  assign y = b['h1]['h2];
endmodule
module top(input [3:0][7:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
