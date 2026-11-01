// § ifcOwnTdTransitiveTds460 (two instances and a modport)
package u;
  typedef logic [3:0] nib_t;
endpackage
package a;
  import u::*;
  typedef struct packed { nib_t x; } own_s;
endpackage
interface bfm (input logic clk);
  import a::*;
  own_s s;
  modport mp (input s);
endinterface
module top;
  logic clk;
  bfm i0 (.clk(clk));
  bfm i1 (.clk(clk));
endmodule
