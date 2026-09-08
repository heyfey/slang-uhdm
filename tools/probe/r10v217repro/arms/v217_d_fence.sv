// v217 arm D — THE SHAPE FENCE AT THE TRANSITIVE HOP (§ 203's packed-struct
// fence). A packed struct, an unpacked struct, a fixed-size unpacked array and
// the three dynamic containers, all declared in a package that is reached ONLY
// transitively.
package pf0;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } pf_packed_t;
  typedef struct        { int x; int y;                 } pf_unpacked_t;
  pf_packed_t   f0_packed;
  pf_unpacked_t f0_unpacked;
  int           f0_arr [0:3];
  int           f0_dyn [];
  int           f0_q   [$];
  int           f0_aa  [string];
  logic [7:0]   f0_vec;
endpackage

package pf1;
  import pf0::*;
  int f1_v;
endpackage

module vf_hop;
  import pf1::*;
  logic vf_hop_clk;
endmodule

module vf_direct;
  import pf0::*;
  logic vf_direct_clk;
endmodule
