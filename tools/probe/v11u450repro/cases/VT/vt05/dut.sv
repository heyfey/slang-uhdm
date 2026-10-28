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
  typedef logic [1:0] two_t;
  two_t t;
  logic [3:0] q;
endinterface
module top;
  logic clk;
  bfm i0 (.clk(clk));
endmodule
