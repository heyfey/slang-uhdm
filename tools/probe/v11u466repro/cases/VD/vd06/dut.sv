// § ifcBodyImpDeepTrans466
package b;
  import c::*;
endpackage
package c;
  typedef logic [3:0] c_t;
endpackage
package a;
  import b::*;
endpackage
module sub(input logic clk);
  import a::*;
  logic v;
endmodule
module top(input logic clk);
  sub u(clk);
endmodule
