// § transImpClassKeys466
package r;
  class C;
    typedef C this_type;
    int rr;
  endclass
endpackage
package q;
  import r::*;
  class C;
    typedef C this_type;
    int qq;
  endclass
  typedef logic [3:0] q_t;
endpackage
import q::*;
interface ifc(input logic clk);
  q_t v;
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
