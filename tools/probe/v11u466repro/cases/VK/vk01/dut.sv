// § transImpClassKeys466
package r;
  class X;
    typedef X this_type;
  endclass
endpackage
package q;
  typedef logic [3:0] X;
  import r::*;
  class Q;
  endclass
endpackage
import q::*;
interface ifc(input logic clk);
  typedef logic [1:0] own_t;
  own_t v;
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
