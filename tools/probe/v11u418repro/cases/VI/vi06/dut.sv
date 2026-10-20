// § ifcFileScopeImportListing418
package p;
  typedef logic [3:0] nib_t;
  typedef struct packed { logic a; logic b; } s_t;
  function automatic int f(int a); return a + 1; endfunction
  task automatic t(input int a); endtask
endpackage
import p::*;
interface ifc (input logic clk);
endinterface
module top;
  logic c;
  for (genvar i = 0; i < 2; i++) begin : g
    ifc u (.clk(c));
  end
endmodule
