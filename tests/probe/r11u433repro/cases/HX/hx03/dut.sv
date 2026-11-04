// § caUnsizedRhsClonePerInst193 (residue: a whole-name Lhs, the sister ground)
module sub(input [15:0] b, output y, z);
  assign y = b['b1];
  assign z = b['o7];
endmodule
module top(input [15:0] b, output y, z);
  sub u(.b(b), .y(y), .z(z));
endmodule
