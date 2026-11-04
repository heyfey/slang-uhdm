// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output y);
  assign y = b[$clog2('h8)];
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
