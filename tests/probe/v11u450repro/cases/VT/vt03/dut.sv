// § ifcBodyImpTransitiveTds450
package u;
  typedef logic [3:0] nib_t;
endpackage
package a;
  import u::*;
  int k;
endpackage
package b;
  import a::*;
  int j;
endpackage
interface bfm (input logic clk);
  import b::*;
endinterface
module top;
  logic clk;
  bfm i0 (.clk(clk));
endmodule
