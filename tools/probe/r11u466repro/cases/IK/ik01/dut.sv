// § transImpClassKeys466
package b;
  class base;
    typedef base this_type;
  endclass
  typedef logic [3:0] b_t;
endpackage
package a;
  import b::*;
  class C;
    typedef C this_type;
    int x;
  endclass
  typedef logic [7:0] a_t;
endpackage
import a::*;
interface ifc(input logic clk);
  a_t v;
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
