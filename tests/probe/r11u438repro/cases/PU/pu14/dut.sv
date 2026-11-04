// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output y);
  assign #1 y = b['hA];
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
