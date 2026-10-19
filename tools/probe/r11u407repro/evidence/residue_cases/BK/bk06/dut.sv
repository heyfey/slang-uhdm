// residue (no law landed): $bits of a type in a class parameter, see README
class c #(parameter P = $bits(int));
  localparam Q = {3{1'b0}};
  int x = $bits(int);
endclass
module test;
  c #(5) h;
endmodule
