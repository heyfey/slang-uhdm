// VERIFIER arm v1 — adversarial cells for the widened `= null` arm and the
// time gate: shapes the implementer's a1/a2 grids never generate.
interface vifx;
  logic a;
endinterface

package pv;

  class basev;
  endclass

  typedef basev basev_t;
  typedef chandle ch_t;
  typedef time    tm_t;
  typedef virtual vifx vifx_t;

  class cparam #(int W = 8);
  endclass

  class cv;
    // --- NULL axis, cells a2 never wrote ------------------------------------
    static basev   n01_stat_h  = null;   // STATIC class handle
    static chandle n02_stat_ch = null;   // STATIC chandle
    basev_t        n03_tdef_h  = null;   // TYPEDEF'd class handle
    ch_t           n04_tdef_ch = null;   // TYPEDEF'd chandle
    vifx_t         n05_tdef_vi = null;   // TYPEDEF'd virtual interface
    cparam #(4)    n06_spec_h  = null;   // SPECIALIZED generic class handle
    rand basev     n07_rand_h  = null;   // rand class handle
    local chandle  n08_loc_ch  = null;   // local chandle
    const basev    n09_cst_h   = null;   // const class handle
    // --- TIME axis, cells a1 never wrote ------------------------------------
    tm_t      n10_tdef_tm = 5ns;   // TYPEDEF'd time
    shortreal n11_sreal   = 5ns;   // shortreal (R2 says nothing emitted)
    bit       n12_bit1    = 5ns;   // 1-bit
    logic     n13_lg1     = 5ns;   // 1-bit four-state
    time      n14_zero    = 0ns;   // zero
    time      n15_big     = 100000000s; // overflow of the double->uint64
    bit [2:0] n16_odd     = 5ns;   // odd width
    // --- SYSCALL axis -------------------------------------------------------
    string    n17_sform   = $sformatf("%0d", 3);
    int       n18_clog    = $clog2(8);
  endclass

endpackage
module vtop; vifx ivx(); endmodule
