// § ifcAnsiLogicPortNet450
package p;
  typedef bit [63:0] addr_t;
  class C;
    function void f(addr_t addr);
    endfunction
  endclass
  function void g(addr_t addr);
  endfunction
endpackage
interface bfm (
   input  logic        clk,
   output logic [31:0] addr
);
import p::*;
initial addr <= 0;
endinterface
module top;
  logic clk;
  logic [31:0] a;
  bfm u (.clk(clk), .addr(a));
endmodule
