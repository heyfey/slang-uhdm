// § transImpClassKeys466
package r;
  class R #(int N = 1);
    typedef R #(N) this_type;
    int a [N];
  endclass
  typedef R #(2) r2_t;
endpackage
package q;
  import r::*;
  typedef logic [3:0] q_t;
endpackage
import q::*;
interface ifc(input logic clk);
  q_t v;
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
