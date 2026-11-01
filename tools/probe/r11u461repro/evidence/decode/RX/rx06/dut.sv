// decode case (no law of this pass): the pipelined_get_put head chain, see README
package a;
  parameter logic [3:0] PA = 1;
endpackage
package b;
  import a::*;
endpackage
module top;
  import b::*;
endmodule
