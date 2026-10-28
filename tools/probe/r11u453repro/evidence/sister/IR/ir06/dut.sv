// sister-ground face: a module variable initializer reading an imported package variable (ModuleEmit initializer writer)
package c;
  int vc;
endpackage
module sub;
  import c::*;
  int x = vc;
endmodule
module top;
  sub u1();
  sub u2();
endmodule
