// decode case (no law of this pass): the pipelined_get_put head chain, see README
package p;
  logic [11:0] w;
  parameter int N = $bits(w);
  parameter int M = (N+7)/8;
endpackage
module top;
  import p::*;
endmodule
