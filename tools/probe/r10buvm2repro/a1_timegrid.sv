// r10buvm2 ARM a1 ??? UVM-FREE class-property TIME-INITIALIZER grid.
//
// One written declaration per line; the LINE NUMBER is the cell key (cells.py).
// The axes the brief named: property TYPE x initializer KIND x static/automatic,
// plus the unit axis the SS srlgTimeLitVal table claims is TIMESCALE-INDEPENDENT.
//
// Read `time phase_timeout = 9200s;` (uvm_root.svh) as cell k01.
package p1;

  class base1;
  endclass

  class c1;
    // --- k01..k07: the UNIT axis on a `time` property ------------------------
    time k01_s     = 9200s;
    time k02_ms    = 7ms;
    time k03_us    = 7us;
    time k04_ns    = 7ns;
    time k05_ps    = 7ps;
    time k06_fs    = 7fs;
    time k07_frac  = 1.5ns;
    // --- k08..k10: the PROPERTY-TYPE axis, same literal ----------------------
    int  k08_int   = 5ns;
    realtime k09_rt = 5ns;
    integer k10_ig = 5ns;
    // --- k11..k13: the STATIC / CONST / VISIBILITY axis ----------------------
    static time k11_stat = 3ns;
    const time  k12_cst  = 4ns;
    local time  k13_loc  = 6ns;
    // --- k14..k16: CONTROLS on the same property type ------------------------
    time k14_plain = 5;          // plain integer literal into a `time` property
    time k15_none;               // no initializer at all
    time k16_expr  = 5ns + 3ns;  // a FOLD-NEEDING expression, not a literal
    // --- k17..k23: the WIDTH axis.  Is the size/decompile split "the typespec
    //     is a time_typespec" or merely "the width is already 64"?  longint is
    //     the cell that decides it; the two readings disagree there and only
    //     there.  k23 also tests the MASK adjustSize applies (9200s does not
    //     fit in 32 bits).
    longint  k17_li  = 5ns;
    shortint k18_si  = 5ns;
    byte     k19_by  = 5ns;
    bit [7:0] k20_bt = 5ns;
    real     k21_re  = 5ns;
    logic [63:0] k22_lg = 5ns;
    int      k23_mask = 9200s;
    logic [127:0] k24_wide = 5ns;   // width > 64: does the mask/size still hold?
  endclass

endpackage
