// sister-ground face: a module variable initializer reading an imported package variable (ModuleEmit initializer writer)
package c;
  logic [7:0] vc;
endpackage
module top;
  import c::*;
  wire [7:0] w = vc;
endmodule
