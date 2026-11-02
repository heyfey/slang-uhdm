// § transImpClassKeys466
package r;
  class R;
    typedef R this_type;
  endclass
endpackage
package q;
  import r::*;
  class Q;
    typedef Q this_type;
  endclass
  typedef logic [3:0] q_t;
endpackage
import q::*;
module sub(input logic clk);
  q_t v;
endmodule
module top(input logic clk);
  sub s1(clk);
  sub s2(clk);
endmodule
