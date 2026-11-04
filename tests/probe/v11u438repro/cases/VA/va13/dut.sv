// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output y);
  assign w = b['h5];
  assign y = w;
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
