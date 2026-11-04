// § cloneValFormalUnnamed474 (attack: untyped value formals, no registry)
package u; parameter int P1 = 5; class R #(type T = int); int y; endclass endpackage
package a; import u::*;
  class A #(W = 1, V = 2); typedef A #(W, V) this_t; int z; endclass
endpackage
package b; import a::*; class K; localparam w = 16; localparam v = 32; endclass typedef A #(K::w, K::v) A_t; endpackage
package c; import a::*; import b::*; class E; A_t h; endclass endpackage
module top; import c::*; endmodule
