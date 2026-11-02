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
module top(input logic clk, output logic o);
  assign o = clk;
endmodule
