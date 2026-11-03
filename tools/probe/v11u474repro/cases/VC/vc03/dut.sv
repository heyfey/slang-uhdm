// § cloneValFormalUnnamed474 (attack: value and type formals mixed)
package u; parameter int P1 = 5; class R #(type T = int); int y; endclass endpackage
package a; import u::*;
  class A #(int W = 1, type T = int); typedef A #(W, T) this_t; T z; endclass
endpackage
package b; import a::*; class K; localparam w = 16; localparam v = 32; endclass typedef A #(K::w, byte) A_t; endpackage
package c; import a::*; import b::*; class E; A_t h; endclass endpackage
module top; import c::*; endmodule
