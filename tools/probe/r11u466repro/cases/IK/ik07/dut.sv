// § transImpClassKeys466
package a;
  import b::*;
  class C;
    typedef C this_type;
  endclass
  typedef logic [7:0] a_t;
endpackage
package b;
  class base;
    typedef base this_type;
  endclass
  typedef logic [3:0] b_t;
endpackage
import a::*;
module top(input logic clk, output logic o);
  a_t v;
  assign o = clk;
endmodule
