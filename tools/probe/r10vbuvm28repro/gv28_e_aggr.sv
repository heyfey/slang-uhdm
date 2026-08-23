// r10vbuvm28 arm E — AGGREGATE MULTIPLIERS + INSTANCES + GENERATE + FOREACH.
package pe;
  typedef enum { G0, G1 } ge_t;
  typedef struct packed { ge_t c; bit [7:0] d; } gps_t;   // 0 + 8
  typedef gps_t  gps_fix_t [4];       // 4 x 8
  typedef gps_t  gps_dyn_t [];        // unsized -> 8
  typedef gps_t  gps_q_t   [$];
  typedef gps_t  gps_aa_t  [string];
  typedef ge_t   ge_pk_t;
  typedef struct packed { gps_t inner; ge_t e; } gnest_t; // 8 + 0
  typedef struct packed { ge_t [1:0] pe; bit [1:0] b; } gpkdim_t; // 2*0 + 2
endpackage

interface gif;
  typedef enum { IF0, IF1 } ife_t;
  ife_t sig;
  int   w;
  initial w = $bits(sig);
endinterface

module leaf #(parameter int P = 1) (input logic clk);
  import pe::*;
  ge_t   lv;
  gps_t  ls;
  gps_t  sdyn_leaf [];
  int    r [8];
  bit    d [];
  initial begin
    r[0] = $bits(ge_t);
    r[1] = $bits(gps_t);
    r[2] = $bits(pe::gps_fix_t);
    r[3] = $bits(sdyn_leaf);   // dynamic-array VARIABLE, not the type
    r[4] = $bits(pe::gnest_t);
    r[5] = $bits(pe::gpkdim_t);
    r[6] = $bits(pe::ge_pk_t);
    d = new [$bits(ge_t)];
    d = new [$bits(gps_t)];
  end
endmodule

module gv28_e_aggr;
  import pe::*;
  logic clk;
  leaf #(1) u1 (.clk(clk));
  leaf #(2) u2 (.clk(clk));
  leaf #(3) u3 (.clk(clk));
  gif  u_if ();
  ge_t   earr [3];
  gps_t  sarr [4];
  gps_t  sdyn [];
  gps_t  sq   [$];
  gps_t  saa  [string];
  int    acc;
  int    r [10];
  bit    dd [];
  initial begin
    r[0] = $bits(pe::gps_fix_t);
    r[1] = $bits(sdyn);        // dynamic-array VARIABLE
    r[2] = $bits(sq);          // queue VARIABLE
    r[3] = $bits(saa);         // assoc VARIABLE
    r[4] = $bits(gnest_t);
    r[5] = $bits(gpkdim_t);
    // NESTED new inside new
    // NOTE: `new [x] (new [y])` is a Surelog GRAMMAR limitation (PA0207), not ours.
    dd = new [$bits(ge_t)] (dd);
    foreach (earr[i]) acc += $bits(earr[i]);
    foreach (sarr[j]) acc += $bits(sarr[j]);
  end
  generate
    if (1) begin : gblk
      typedef enum { GB0, GB1 } gbe_t;
      gbe_t gv;
      int   gr;
      initial gr = $bits(gbe_t) + $bits(gv);
    end
  endgenerate
endmodule
