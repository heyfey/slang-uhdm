// § specValueArgRefObj470 (a module variable)
package p;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
package t;
  class K; localparam w = 16; endclass
endpackage
module top; import p::*; import t::*; C #(K::w, 4) h; endmodule
