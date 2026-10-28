// § ifcBodyImpTransitiveTds450
package u;
  typedef logic [3:0] nib_t;
endpackage
package a;
  import u::*;
  int k;
endpackage
interface bfm (input logic clk);
  import a::*;
  modport mp (input clk);
endinterface
module m (bfm.mp b);
endmodule
module top;
  logic clk;
  bfm i0 (.clk(clk));
  m mm (.b(i0));
endmodule
