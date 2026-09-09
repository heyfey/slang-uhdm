// r10uvm225 arm a13_ranges — the array_net's RANGE and vpiSize per kind, and
// PARAM-sized dims (the def view keeps them symbolic).
typedef logic [7:0] tvr225_t;

package p225r;
  parameter int PN225 = 3;
endpackage

interface if225_rng #(parameter int W225 = 4)();
  import p225r::*;
  tvr225_t r_fix1225 [1:0];
  tvr225_t r_fix2225 [4];
  tvr225_t r_fix3225 [2:5];
  tvr225_t r_fixw225 [W225];
  tvr225_t r_fixp225 [PN225];
  tvr225_t r_dyn225  [];
  tvr225_t r_q225    [$];
  tvr225_t r_qb225   [$:3];
  tvr225_t r_as225   [string];
endinterface

module top225_rng();
  if225_rng #(.W225(5)) u_rng225();
endmodule
