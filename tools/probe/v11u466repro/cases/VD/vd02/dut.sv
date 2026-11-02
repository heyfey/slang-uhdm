// § ifcDeepTransEarlierOnly466v
package b;
  import c::*;
endpackage
package c;
  typedef logic [3:0] c_t;
endpackage
package a;
  import b::*;
endpackage
interface ifc(input logic clk);
  import a::*;
  logic v;
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
