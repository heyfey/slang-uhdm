// § namedUnlinkedWrittenOrder207: calls golden links written out of formal order: a module function above its caller, a package function called unqualified and qualified, an imported function, an interface function through a port, a class's own method declared above (controls: the formal order)
package pk;
function automatic int pf(int a, int b = 1, int c = 2); return a + b + c; endfunction
endpackage
import pk::*;
interface bus_if(input logic clk);
  function automatic int ifn(int a, int b = 1, int c = 2); return a * b + c; endfunction
endinterface
class C;
  function int above(int a, int b = 1, int c = 2); return a - b + c; endfunction
  function int use1(int x); return above(.c(x), .b(2), .a(1)) + above(.c(x), .a(3)); endfunction
endclass
module top(input logic clk, input int x, output int o, output int q);
  function automatic int mf(int a, int b = 1, int c = 2); return a + b - c; endfunction
  bus_if b(clk);
  always_comb o = mf(.c(x), .b(2), .a(1)) + pf(.c(x), .a(4)) + pk::pf(.b(x), .a(2), .c(3));
  always_comb q = b.ifn(.c(x), .a(1)) + mf(.b(1), .a(x));
endmodule
