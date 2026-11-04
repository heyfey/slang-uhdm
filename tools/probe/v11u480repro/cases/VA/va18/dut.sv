// § fixArrLocalNamedAggElemTs480 (struct typedef with a member of an enum typedef)
package p;
  typedef enum { R, G } c_t;
  typedef struct { c_t c; int v; } op_t;
  task automatic t(output int o);
    op_t acc[2];
    acc[0].c = G;
    o = acc[0].c;
  endtask
endpackage
module top;
  import p::*;
  int x;
  initial t(x);
endmodule
