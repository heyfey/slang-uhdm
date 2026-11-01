// § ifcOwnTdTransitiveTds460 (two imported packages, one own+transitive)
package u;
  typedef logic [3:0] nib_t;
endpackage
package a;
  import u::*;
  typedef int own_t;
endpackage
package z;
  typedef byte zb_t;
endpackage
interface bfm (input logic clk);
  import z::*;
  import a::*;
  zb_t zz;
endinterface
module top;
  logic clk;
  bfm i (.clk(clk));
endmodule
