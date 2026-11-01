// decode case (no law of this pass): the pipelined_get_put head chain, see README
package p;
  typedef enum {A, B} e_t;
  typedef struct packed { e_t o; logic [7:0] d; } s_t;
  parameter int N = $bits(s_t);
  parameter int M = (N+7)/8;
  typedef bit [N-1:0] v_t;
endpackage
module top;
  import p::*;
  v_t x;
endmodule
