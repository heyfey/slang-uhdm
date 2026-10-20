// § ifcFileScopeImportListing418
package p;
  typedef logic [3:0] nib_t;
  typedef struct packed { logic a; logic b; } s_t;
  function automatic int f(int a); return a + 1; endfunction
endpackage
import p::*;
interface ifc (input logic clk);
  typedef logic [1:0] my_t;
  my_t m;
endinterface
module top;
  logic c;
  ifc u (.clk(c));
endmodule
