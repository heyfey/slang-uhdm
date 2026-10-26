// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output y, z);
  assign y = b['hA];
  assign z = b[3];
endmodule
module top(input [15:0] b, output y, z);
  sub u(.b(b), .y(y), .z(z));
endmodule
