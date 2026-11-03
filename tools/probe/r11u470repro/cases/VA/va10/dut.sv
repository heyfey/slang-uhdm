// § specValueArgRefObj470
package q; parameter int A = 1; parameter int B = 2; endpackage
package p;
  import q::*;
  class C #(int W = 8, int D = 8);
    typedef C #(W, D) this_t;
    int x;
  endclass
endpackage
module top; import p::*; C h; endmodule
