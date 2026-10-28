// sister-ground face: a module variable initializer reading an imported package variable (ModuleEmit initializer writer)
package c;
  int vc;
endpackage
module top;
  import c::*;
  if (1) begin : g
    int x = vc;
  end
endmodule
