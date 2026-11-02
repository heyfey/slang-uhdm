// § emptyListClassKeys466
package a;
  class C;
    typedef C this_type;
  endclass
endpackage
import a::*;
program prg(input logic clk);
  logic v;
endprogram
module top(input logic clk);
  prg p(clk);
endmodule
