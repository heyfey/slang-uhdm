// § clsTfOpFoldTsLate423
package p;
  typedef logic [7:0] b_t;
  parameter b_t M = 8'h0F;
endpackage
module top;
  import p::*;
  task t(input b_t w, output b_t o);
    o = w & M;
  endtask
endmodule
