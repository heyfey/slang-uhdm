// § ifcOwnTdTransitiveTds460 (interface instantiated in a generate loop, virtual interface handle)
package u;
  typedef logic [3:0] nib_t;
endpackage
package a;
  import u::*;
  typedef nib_t own_t;
endpackage
interface bfm (input logic clk);
  import a::*;
  own_t v;
endinterface
module top;
  logic clk;
  for (genvar g = 0; g < 2; g++) begin : gl
    bfm i (.clk(clk));
  end
  virtual bfm vh;
endmodule
