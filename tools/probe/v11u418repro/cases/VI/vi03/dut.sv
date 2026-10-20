// § ifcFileScopeImportListing418
package p;
  typedef logic [3:0] nib_t;
  typedef struct packed { logic a; logic b; } s_t;
  function automatic int f(int a); return a + 1; endfunction
  task automatic t(input int a); endtask
endpackage
import p::*;
interface ifa (input logic clk);
endinterface
interface ifb (input logic clk);
  logic q;
endinterface
module top;
  logic c;
  ifa ua (.clk(c));
  ifb ub (.clk(c));
endmodule
