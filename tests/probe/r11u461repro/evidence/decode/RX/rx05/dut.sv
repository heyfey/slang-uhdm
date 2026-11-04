// decode case (no law of this pass): the pipelined_get_put head chain, see README
package a;
  typedef enum {X, Y} e_t;
  typedef struct packed { e_t o; logic [7:0] d; } s_t;
  parameter int PA = $bits(s_t);
  parameter int PB = (PA+7)/8;
endpackage
package b;
  import a::*;
endpackage
module top;
  import b::*;
endmodule
