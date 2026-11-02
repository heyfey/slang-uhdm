// § emptyListClassKeys466
package a;
  class C;
    typedef C this_type;
  endclass
endpackage
interface ifc(input logic clk);
  import a::*;
  logic v;
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
