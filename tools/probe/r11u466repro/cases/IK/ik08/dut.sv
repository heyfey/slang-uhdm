// § transImpClassKeys466
package b;
  class kname;
    typedef kname this_type;
  endclass
endpackage
package a;
  import b::*;
  typedef logic [7:0] a_t;
endpackage
package z;
  typedef logic [1:0] kname;
endpackage
import a::*;
import z::*;
module top(input logic clk, output logic o);
  a_t v;
  assign o = clk;
endmodule
