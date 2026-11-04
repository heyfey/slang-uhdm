// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output y);
  assign #1 y = b['h2];
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
