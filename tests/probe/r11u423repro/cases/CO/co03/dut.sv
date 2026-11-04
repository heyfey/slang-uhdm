// § clsTfOpFoldTsLate423
package p;
  typedef logic [7:0] b_t;
  parameter b_t M = 8'h0F;
endpackage
import p::*;
class C;
  task t(b_t w, output b_t o);
    o = w & M;
  endtask
endclass
module top; C c; endmodule
