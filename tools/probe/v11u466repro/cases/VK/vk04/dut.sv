// § transImpClassKeys466
package c;
  class Cc;
    typedef Cc this_type;
  endclass
  typedef logic [1:0] c_t;
endpackage
package b;
  import c::*;
  class Bb;
    typedef Bb this_type;
  endclass
endpackage
package a;
  import b::*;
  class Aa;
  endclass
  typedef logic [2:0] a_t;
endpackage
import a::*;
interface ifc(input logic clk);
  a_t v;
endinterface
module top(input logic clk);
  ifc u(clk);
  a_t w;
endmodule
