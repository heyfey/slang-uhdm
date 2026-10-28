// § ifcBodyImpTransitiveTds450
package u;
  typedef logic [3:0] nib_t;
endpackage
package a;
  import u::*;
  int k;
endpackage
interface bfm (input logic clk, input u::nib_t n);
  import a::*;
endinterface
module top;
  import a::*;
  logic clk; logic [3:0] nn;
  for (genvar g = 0; g < 1; g++) begin : gb
    bfm i0 (.clk(clk), .n(nn));
  end
endmodule
