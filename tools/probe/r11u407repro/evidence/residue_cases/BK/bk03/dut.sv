// residue (no law landed): $bits of a type in a class parameter, see README
module test;
  localparam Max_int = {$bits(int) - 1{1'b1}};
  localparam W = $bits(shortint);
endmodule
