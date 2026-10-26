// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output y);
  assign y = b['d5];
endmodule
module top(input [15:0] b, output y1, y2);
  sub u1(.b(b), .y(y1));
  sub u2(.b(b), .y(y2));
endmodule
