// residue (no law landed): $bits of a type in a class parameter, see README
class c;
  localparam W = $bits(int);
  localparam X = $bits(byte) + 1;
endclass
module test;
endmodule
