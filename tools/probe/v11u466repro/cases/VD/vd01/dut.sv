// § ifcBodyImpDeepTrans466
package d;
  typedef logic [3:0] d_t;
endpackage
package c;
  import d::*;
endpackage
package b;
  import c::*;
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
