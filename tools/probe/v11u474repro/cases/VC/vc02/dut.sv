// § cloneValFormalUnnamed474 (attack: ranged value formals)
package u; parameter int P1 = 5; class R #(type T = int); int y; endclass endpackage
package a; import u::*;
  class A #(bit [5:0] W = 1, logic [7:0] V = 2); typedef A #(W, V) this_t; int z; endclass
endpackage
package b; import a::*; class K; localparam w = 16; localparam v = 32; endclass typedef A #(K::w, K::v) A_t; endpackage
package c; import a::*; import b::*; class E; A_t h; endclass endpackage
module top; import c::*; endmodule
