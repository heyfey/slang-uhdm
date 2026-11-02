// § ifcBodyImpDeepTrans466
package c;
  class cb;
    typedef cb this_type;
  endclass
  typedef logic [2:0] c_t;
endpackage
package b;
  import c::*;
  class base;
    typedef base this_type;
  endclass
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
