// § ifcBodyImpDeepTrans466
package c;
  typedef enum logic [1:0] {X0, X1} c_e;
  typedef struct packed { logic a; logic b; } c_s;
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
  ifc u1(clk);
  ifc u2(clk);
endmodule
