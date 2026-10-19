// residue (no law landed): $bits of a type in a class parameter, see README
class how_wide;
  localparam Max_int = {$bits(int) - 1{1'b1}};
endclass
module test;
endmodule
