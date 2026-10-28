// sister-ground face: a module variable initializer reading an imported package variable (ModuleEmit initializer writer)
package c;
  int vc;
endpackage
module top;
  import c::*;
  int x = vc;
endmodule
