// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output y);
  assign y = b['1];
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
