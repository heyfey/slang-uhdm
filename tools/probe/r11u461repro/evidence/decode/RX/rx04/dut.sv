// decode case (no law of this pass): the pipelined_get_put head chain, see README
package a;
  parameter int PA = 1;
endpackage
package b;
  import a::*;
  parameter int PB = PA + 1;
endpackage
module top;
  import b::*;
endmodule
