// § ifcFileScopeImportListing418
package p;
  typedef logic [3:0] nib_t;
  typedef struct packed { logic a; logic b; } s_t;
  function automatic int f(int a); return a + 1; endfunction
endpackage
import p::*;
interface ifc (input logic clk);
  logic x;
endinterface
module top;
  logic c;
  ifc u1 (.clk(c));
  ifc u2 (.clk(c));
endmodule
