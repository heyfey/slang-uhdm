// sister-ground face: a module variable initializer reading an imported package variable (ModuleEmit initializer writer)
package c;
  int vc;
endpackage
import c::*;
module top;
  int x = vc;
endmodule
