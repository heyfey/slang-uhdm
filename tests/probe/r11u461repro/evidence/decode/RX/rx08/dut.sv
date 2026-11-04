// decode case (no law of this pass): the pipelined_get_put head chain, see README
package z;
  parameter int PA = 1;
endpackage
package b;
  import z::*;
endpackage
module top;
  import b::*;
endmodule
