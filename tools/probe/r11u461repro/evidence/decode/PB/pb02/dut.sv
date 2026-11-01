// decode case (no law of this pass): the pipelined_get_put head chain, see README
package p;
  typedef struct packed { logic [3:0] o; logic [7:0] d; } s_t;
  parameter int N = $bits(s_t);
  parameter int M = (N+7)/8;
endpackage
module top;
  import p::*;
endmodule
