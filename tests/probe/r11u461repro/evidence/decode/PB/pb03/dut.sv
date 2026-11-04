// decode case (no law of this pass): the pipelined_get_put head chain, see README
package p;
  parameter int N = 12;
  parameter int M = (N+7)/8;
endpackage
module top;
  import p::*;
endmodule
