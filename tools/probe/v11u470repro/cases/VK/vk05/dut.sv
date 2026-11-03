// § specValueArgRefObj470 (an enum constant declared in the class)
package p;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
package t;
  import p::*;
  class K; typedef enum {A, B, E = 7} e_t; endclass
  typedef C #(K::E, 4) cfg_t;
endpackage
module top; import t::*; cfg_t h; endmodule
