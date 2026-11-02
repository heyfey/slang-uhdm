// § ifcBodyImpDeepTrans466
package d;
  typedef logic [1:0] d_t;
endpackage
package b;
  import c::*;
  import d::*;
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
