// residue (no law landed): $bits of a type in a class parameter, see README
class c;
  typedef logic [5:0] t_t;
  localparam W = $bits(t_t);
  localparam V = $bits(logic [3:0]);
endclass
module test;
endmodule
