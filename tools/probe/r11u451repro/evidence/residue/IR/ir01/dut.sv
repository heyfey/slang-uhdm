// residue: a module variable initializer reading an imported package variable
package c;
  int vc;
endpackage
module top;
  import c::*;
  int x = vc;
endmodule
