// § transImpClassKeys466
package r;
  class R;
    typedef R this_type;
  endclass
endpackage
package q;
  import r::*;
  typedef logic [3:0] q_t;
endpackage
module top(input logic clk);
  import q::*;
  q_t v;
endmodule
