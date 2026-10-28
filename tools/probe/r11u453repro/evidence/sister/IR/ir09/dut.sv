// sister-ground face: a module variable initializer reading an imported package variable (ModuleEmit initializer writer)
package c;
  int vc;
  parameter int P = 3;
endpackage
module top;
  import c::*;
  int x = P;
  int z = vc[P];
endmodule
