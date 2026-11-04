// § transImpClassKeys466
package d;
  class D;
    typedef D this_type;
  endclass
endpackage
package b;
  import d::*;
  class B;
  endclass
endpackage
package c;
  import d::*;
  class Cc;
  endclass
endpackage
package a;
  import b::*;
  import c::*;
  typedef logic [2:0] a_t;
endpackage
import a::*;
module top(input logic clk);
  typedef logic [1:0] own_t;
  own_t v;
endmodule
