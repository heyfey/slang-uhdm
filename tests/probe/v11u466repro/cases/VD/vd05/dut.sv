// § ifcBodyImpDeepTrans466
package c;
  typedef logic [3:0] c_t;
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
  import a::*;
  ifc u(clk);
endmodule
