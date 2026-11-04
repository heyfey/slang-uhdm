// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output y, z);
  assign y = b['h1], z = b['h2];
endmodule
module top(input [15:0] b, output y, z);
  sub u(.b(b), .y(y), .z(z));
endmodule
