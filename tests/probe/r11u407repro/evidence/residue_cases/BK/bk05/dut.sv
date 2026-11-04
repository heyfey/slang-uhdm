// residue (no law landed): $bits of a type in a class parameter, see README
package p;
  localparam W = $bits(int) - 1;
  class c;
    localparam Z = {2{1'b1}};
    localparam Y = $bits(longint);
  endclass
endpackage
module test;
endmodule
