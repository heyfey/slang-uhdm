// sister-ground face: a module variable initializer reading an imported package variable (ModuleEmit initializer writer)
package c;
  int vc;
endpackage
interface ifc;
  import c::*;
  int x = vc;
endinterface
module top;
  ifc u();
endmodule
