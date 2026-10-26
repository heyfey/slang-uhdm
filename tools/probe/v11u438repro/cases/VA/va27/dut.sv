// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output y);
  wire [15:0] c;
  assign c = b;
  assign y = c['hC];
endmodule
module top(input [15:0] b, output y);
  sub u(.b(b), .y(y));
endmodule
