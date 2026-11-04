// § cloneValFormalUnnamed474 (attack: class localparam beside the formals, registry present)
package u; parameter int P1 = 5; class R #(type T = int); int y; endclass endpackage
package a; import u::*;
  class A #(int W = 1, int V = 2); localparam L = W + V; typedef A #(W, V) this_t; typedef R #(this_t) type_id; int z; endclass
endpackage
package b; import a::*; class K; localparam w = 16; localparam v = 32; endclass typedef A #(K::w, K::v) A_t; endpackage
package c; import a::*; import b::*; class E; A_t h; endclass endpackage
module top; import c::*; endmodule
