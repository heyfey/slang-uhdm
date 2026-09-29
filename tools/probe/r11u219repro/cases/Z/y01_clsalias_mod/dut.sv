// § classTdAliasLastWriter214 — two typedefs specializing one package class, a module importing the package
package p;
  class c #(type T = int);
    T v;
  endclass
  typedef c #(int) bar_pool_t;
  typedef c #(int) ev_pool_t;
  class user;
    ev_pool_t q;
  endclass
endpackage
module top(output int o);
  import p::*;
  assign o = 1;
endmodule
