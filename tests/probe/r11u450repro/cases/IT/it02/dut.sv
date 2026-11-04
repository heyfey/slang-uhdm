// § ifcBodyImpTransitiveTds450
package u;
  typedef logic [3:0] nib_t;
  typedef enum {A, B} ab_e;
  typedef struct packed { logic x; logic y; } xy_s;
endpackage
package a;
  import u::*;
  typedef int own_t;
endpackage
interface bfm (input logic clk);
  import a::*;
endinterface
module top;
  logic clk;
  bfm i (.clk(clk));
endmodule
