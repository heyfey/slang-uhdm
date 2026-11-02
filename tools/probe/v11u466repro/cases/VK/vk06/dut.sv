// § transImpClassKeys466
package r;
  class R;
    typedef R this_type;
  endclass
endpackage
package q;
  import r::*;
  class Q;
  endclass
endpackage
package p;
  import q::*;
  typedef logic [3:0] p_t;
  p_t pv;
endpackage
module top(input logic clk);
  import p::*;
  p_t v;
endmodule
