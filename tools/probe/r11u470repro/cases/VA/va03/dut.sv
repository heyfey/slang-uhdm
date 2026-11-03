// § specValueArgRefObj470
package p;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
package t;
  import p::*;
  parameter int P1 = 16;
  parameter int P2 = 32;
  typedef C #(P1, P2) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
