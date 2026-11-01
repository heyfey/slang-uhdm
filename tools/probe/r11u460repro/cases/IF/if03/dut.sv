// § ifcOwnTdTransitiveTds460 (two interfaces, one importing only the agent package)
package u;
  typedef logic [3:0] nib_t;
  typedef enum {A, B} ab_e;
endpackage
package a;
  import u::*;
  typedef int own_t;
  typedef nib_t wrap_t;
endpackage
interface drv (input logic clk);
  import u::*;
  import a::*;
endinterface
interface mon (input logic clk);
  import a::*;
endinterface
module top;
  logic clk;
  drv d (.clk(clk));
  mon m (.clk(clk));
endmodule
