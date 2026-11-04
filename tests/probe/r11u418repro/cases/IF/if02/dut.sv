// § ifcFileScopeImportListing418
package p;
  typedef struct packed { logic a; logic [1:0] b; } s_t;
  typedef enum logic [1:0] { A, B } e_t;
  typedef logic [3:0] nib_t;
  function automatic int f(int a); return a + 1; endfunction
endpackage
import p::*;
interface ifc (input logic clk);
  logic x;
endinterface
module top;
  logic c;
  ifc u (.clk(c));
endmodule
