// § ifcFileScopeImportListing418
package p;
  typedef logic [3:0] nib_t;
  typedef struct packed { logic a; logic b; } s_t;
  function automatic int f(int a); return a + 1; endfunction
endpackage
import p::*;
module m (input logic clk);
endmodule
module top;
  logic c;
  m u (.clk(c));
endmodule
