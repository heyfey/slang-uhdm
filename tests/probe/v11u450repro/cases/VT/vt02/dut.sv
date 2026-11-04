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
endinterface
module top;
endmodule
