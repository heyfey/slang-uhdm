// § emptyListClassKeys466
package a;
  class C;
    typedef C this_type;
  endclass
endpackage
import a::*;
interface ifc(input logic clk);
  logic v;
endinterface
module top(input logic clk);
  ifc u1(clk);
  ifc u2(clk);
endmodule
