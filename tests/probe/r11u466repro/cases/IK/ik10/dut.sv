// § transImpClassKeys466
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
  typedef logic [3:0] b_t;
endpackage
package a;
  import b::*;
  typedef logic [7:0] a_t;
endpackage
module top(input logic clk);
  import a::*;
  a_t v;
endmodule
