// decode case (no law of this pass): the pipelined_get_put head chain, see README
package a;
  typedef struct packed { logic [3:0] o; logic [7:0] d; } s_t;
  parameter int PA = $bits(s_t);
endpackage
package b;
  import a::*;
endpackage
module top;
  import b::*;
endmodule
