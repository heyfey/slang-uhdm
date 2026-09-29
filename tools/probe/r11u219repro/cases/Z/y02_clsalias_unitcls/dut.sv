// § classTdAliasLastWriter214 — the specialization-alias typedef with a $unit import and a $unit class writing last
package p;
  class c #(type T = int);
    T v;
  endclass
  typedef c #(byte) bar_pool_t;
  typedef c #(byte) ev_pool_t;
endpackage
import p::*;
class holder;
  ev_pool_t e;
endclass
module top(output int o);
  assign o = 2;
endmodule
