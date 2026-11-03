// § thisTdRegDefView474 (decode grid: the vpiInstance of a specialization's class-local this_t; ours writes no copy on these shapes)
package a;
  class A #(int W = 1, int V = 2);
    typedef A #(W, V) this_t;
    int x;
  endclass
endpackage
package b;
  import a::*;
  class K;
    localparam w = 16;
    localparam v = 32;
  endclass
  typedef A #(K::w, K::v) A_t;
endpackage
