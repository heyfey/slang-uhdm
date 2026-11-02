// § transImpClassKeys466
package r;
  class R;
    typedef R this_type;
  endclass
  class S;
  endclass
endpackage
package q;
  import r::R;
  typedef logic [3:0] q_t;
endpackage
import q::*;
interface ifc(input logic clk);
  q_t v;
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
