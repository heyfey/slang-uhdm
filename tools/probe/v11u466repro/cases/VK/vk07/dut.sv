// § transImpClassKeys466
package a;
  import b::*;
  typedef logic [2:0] a_t;
endpackage
package b;
  class Bb;
    typedef Bb this_type;
  endclass
endpackage
import a::*;
interface ifc(input logic clk);
  a_t v;
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
