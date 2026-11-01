// decode case (no law of this pass): the pipelined_get_put head chain, see README
package a;
  typedef enum logic [2:0] {N0, N1, N2} e_t;
endpackage
package b;
  import a::*;
endpackage
module top;
  import b::*;
endmodule
