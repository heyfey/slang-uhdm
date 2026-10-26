// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output y);
  assign (weak0, weak1) y = b['h8];
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
