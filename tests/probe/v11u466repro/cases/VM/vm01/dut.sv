// § emptyListClassKeys466
package a;
  class C;
    typedef C this_type;
  endclass
endpackage
import a::*;
module sub(input logic clk);
  logic v;
endmodule
module top(input logic clk);
  sub s(clk);
endmodule
