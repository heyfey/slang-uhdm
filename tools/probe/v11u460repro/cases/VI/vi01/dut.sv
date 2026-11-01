// § ifcOwnTdTransitiveTds460 (interface with its own typedef too)
package u;
  typedef logic [3:0] nib_t;
  typedef enum {A, B} ab_e;
endpackage
package a;
  import u::*;
  typedef int own_t;
endpackage
interface bfm (input logic clk);
  import a::*;
  typedef bit [1:0] loc_t;
  loc_t l;
  own_t o;
endinterface
module top;
  logic clk;
  bfm i (.clk(clk));
endmodule
