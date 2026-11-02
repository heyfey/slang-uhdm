// § ifcBodyImpDeepTrans466
package c;
  typedef logic [3:0] c_t;
  typedef logic [1:0] c2_t;
endpackage
package b;
  import c::c_t;
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
