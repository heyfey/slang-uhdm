// § emptyListClassKeys466
package b;
  class base;
    typedef base this_type;
  endclass
endpackage
package a;
  import b::*;
  class C;
    typedef C this_type;
  endclass
endpackage
import a::*;
interface ifc(input logic clk);
  logic v;
endinterface
module top(input logic clk);
  ifc u(clk);
endmodule
