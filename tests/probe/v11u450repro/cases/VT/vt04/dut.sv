// § ifcBodyImpTransitiveTds450
package u;
  typedef logic [3:0] nib_t;
  typedef struct packed { logic a; } s_t;
endpackage
package w;
  typedef int w_t;
endpackage
package a;
  import u::*;
  import w::*;
  int k;
endpackage
package k2;
  int z;
endpackage
interface bfm (input logic clk);
  import a::*;
  import k2::*;
endinterface
module top;
  logic clk;
  bfm i0 (.clk(clk));
endmodule
