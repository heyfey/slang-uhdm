// § ifcOwnTdTransitiveTds460 (control: interface imports the transitive package directly too)
package u;
  typedef logic [3:0] nib_t;
endpackage
package a;
  import u::*;
  typedef int own_t;
endpackage
interface bfm (input logic clk);
  import u::*;
  import a::*;
  nib_t n;
endinterface
module top;
  logic clk;
  bfm i (.clk(clk));
endmodule
