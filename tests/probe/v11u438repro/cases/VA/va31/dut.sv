// § caPlainLhsUnsizedClone438
module other(input [15:0] b, output y);
  assign y = b['h2];
endmodule
module top(input [15:0] b, output y);
  other u(.b(b), .y(y));
endmodule
module spare(input [15:0] b, output y);
  assign y = b['h4];
endmodule
