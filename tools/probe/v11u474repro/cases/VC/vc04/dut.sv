// § cloneValFormalUnnamed474 (attack: typedef of the package typedef in a third package)
package u; parameter int P1 = 5; class R #(type T = int); int y; endclass endpackage
package a; import u::*;
  class A #(int W = 1, int V = 2); typedef A #(W, V) this_t; int z; endclass
endpackage
package b; import a::*; class K; localparam w = 16; localparam v = 32; endclass typedef A #(K::w, K::v) A_t; endpackage
package c; import a::*; import b::*; typedef A_t A2_t; class E; A2_t h; endclass endpackage
module top; import c::*; endmodule
