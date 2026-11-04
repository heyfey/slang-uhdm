// § ifcBodyImpTransitiveTds450
package u;
  typedef logic [3:0] nib_t;
  typedef enum {A, B} ab_e;
endpackage
package a;
  import u::*;
  int k;
endpackage
interface bfm (input logic clk);
  import a::*;
endinterface
module top;
  logic clk;
  bfm i0 (.clk(clk));
  bfm i1 (.clk(clk));
endmodule
