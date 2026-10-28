// § ifcBodyImpTransitiveTds450
package u;
  typedef logic [3:0] nib_t;
  typedef enum {A, B} ab_e;
  typedef struct packed { logic x; logic y; } xy_s;
endpackage
package a;
  import u::*;
  int k;
endpackage
interface bfm (input logic clk);
  import a::*;
  import u::*;
endinterface
module top;
  logic clk;
  bfm i (.clk(clk));
endmodule
