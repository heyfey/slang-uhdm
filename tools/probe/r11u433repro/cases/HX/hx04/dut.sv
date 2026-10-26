// § caUnsizedRhsClonePerInst193 (residue: a whole-name Lhs, the sister ground)
module sub(input [15:0] b, output logic y, z);
  always_comb y = b['hA];
  wire w = b['hB];
  assign z = w;
endmodule
module top(input [15:0] b, output y, z);
  sub u(.b(b), .y(y), .z(z));
endmodule
