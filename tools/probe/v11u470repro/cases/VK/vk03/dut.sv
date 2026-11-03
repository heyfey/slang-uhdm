// § specValueArgRefObj470 (the class name is a typedef of a specialization)
package p;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
package t;
  import p::*;
  class KK #(int N = 2); localparam w = 16; endclass
  typedef KK #(5) K;
  typedef C #(K::w, 4) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
