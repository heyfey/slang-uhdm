// § emptyListClassKeys466
package b;
  class B;
    typedef B this_type;
  endclass
endpackage
package a;
  import b::*;
  class C;
  endclass
endpackage
import a::*;
interface ifc #(parameter int W = 1) (input logic clk);
  logic [W-1:0] v;
endinterface
module top(input logic clk);
  ifc #(2) u1(clk);
  ifc #(3) u2(clk);
endmodule
