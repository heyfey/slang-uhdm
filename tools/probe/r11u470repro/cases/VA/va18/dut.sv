// § specValueArgRefObj470
package p;
  class C #(int W = 8, int D = 8);
    int x;
  endclass
endpackage
class K; localparam w = 16; localparam d = 32; endclass
import p::*;
typedef C #(K::w, K::d) cfg_t;
module top; cfg_t h; endmodule
