// v1 — CROSS-PACKAGE NAME COLLISION (the r11u49 R1 warning at the import face).
// `hasMemberSelectOf` keys on a BARE NAME and ANY package.  Here package pa
// member-selects ITS `HIT`; package pb's identically-named `HIT` is never
// selected anywhere.  A module imports pb::HIT ONLY.  Golden must keep pb's
// DEF import copy TAGGED; a name-keyed law flattens it.
package pa;
  typedef struct { int unsigned a; int unsigned b; } sa_t;
  localparam sa_t HIT = '{a: 4, b: 8};
  typedef logic [HIT.a-1:0] av_t;           // package-scope member select on pa::HIT
endpackage

package pb;
  typedef struct { int unsigned a; int unsigned b; } sb_t;
  localparam sb_t HIT = '{a: 1, b: 2};      // NEVER selected anywhere
  localparam sb_t MISS = '{a: 3, b: 5};     // control: never selected, no twin
endpackage

module v1q import pb::HIT; import pb::MISS; (input logic clk, output int unsigned o);
  assign o = HIT.a + MISS.b;                // a MODULE select: declines per g1 PMOD
endmodule

module v1a import pa::*; (input logic clk);
  av_t d;
  assign d = '0;
endmodule

module v1top(input logic clk);
  int unsigned oo;
  v1q u_q (.clk(clk), .o(oo));
  v1a u_a (.clk(clk));
endmodule
