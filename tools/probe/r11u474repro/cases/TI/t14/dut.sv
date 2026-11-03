// § thisTdRegDefView474 (decode grid: the vpiInstance of a specialization's class-local this_t; ours writes no copy on these shapes)
package u; class R #(type T = int); T t; endclass endpackage
package a;
  import u::*;
  class A #(int W = 1, int V = 2);
    typedef A #(W, V) this_t;
    typedef R #(this_t) type_id;
  endclass
endpackage
package b;
  import a::*;
  typedef A #(16, 32) A_t;
endpackage

