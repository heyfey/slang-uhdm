// § caPlainLhsUnsizedClone438
module sub(input [15:0] b, output y, output z);
  assign y = b['hA], z = b['hB];
endmodule
module top(input [15:0] b, output y, z);
  sub u(.b(b), .y(y), .z(z));
endmodule
