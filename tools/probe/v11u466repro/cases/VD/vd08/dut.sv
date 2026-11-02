// § ifcDeepTransEarlierOnly466v
package c;
  typedef logic [3:0] c_t;
endpackage
package a;
  import b::*;
endpackage
package b;
  import c::*;
endpackage
interface ifc(input logic clk);
  import a::*;
  logic v;
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
