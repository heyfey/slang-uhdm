// § caPlainLhsUnsizedClone438 (a fill literal index)
module sub(input [1:0] b, output y);
  assign y = b['0];
endmodule
module top(input [1:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
