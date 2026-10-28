// § ifcBodyImpTransitiveTds450
package u;
  typedef logic [3:0] nib_t;
  class C; int x; endclass
endpackage
package a;
  import u::*;
  export u::*;
  int k;
endpackage
interface bfm (input logic clk);
  import a::*;
endinterface
module top;
  logic clk;
  bfm i0 (.clk(clk));
endmodule
