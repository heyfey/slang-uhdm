// r10uvm136 arm A — TYPEDEF KIND x class property.  One package class; every
// property's declared type is a NAMED TYPEDEF declared BEFORE the class.
// Names deliberately unlike each other (no a_t/b_t/c_t self-confirming grid).
package Kpkg;

  typedef struct packed { bit [7:0] lo; bit [7:0] hi; int unsigned STRIDE; } wire_range_ps2;
  typedef struct packed { logic [7:0] q; logic [7:0] r; } NibblePair_ps4;
  typedef struct packed { logic [3:0] q; int unsigned n; } mixedFour_ps4m;
  typedef struct { int alpha; string beta; } Loose_us;
  typedef union packed { bit [15:0] whole; NibblePair_ps4 parts; } Uword_pu;
  typedef union { int i9; real r9; } uLoose_uu;
  typedef enum bit [2:0] { E_ZERO = 0, E_SEVEN = 7 } Tri_e;
  typedef logic [11:0] Twelve_lv;
  typedef bit [5:0] six_bv;
  typedef int intAlias_i;
  typedef string strAlias_s;
  typedef wire_range_ps2 chain_lvl1;
  typedef chain_lvl1 chain_lvl2;

  class Holder78;
    wire_range_ps2 k01_ps2;
    NibblePair_ps4 k02_ps4;
    mixedFour_ps4m k03_ps4m;
    Loose_us       k04_us;
    Uword_pu       k05_pu;
    uLoose_uu      k06_uu;
    Tri_e          k07_e;
    Twelve_lv      k08_lv;
    six_bv         k09_bv;
    intAlias_i     k10_i;
    strAlias_s     k11_s;
    chain_lvl2     k12_chain;
    Holder78       k13_self;
    // anonymous (NOT a named typedef) controls
    struct packed { bit [7:0] one; bit [7:0] two; } k14_anonps;
    logic [9:0] k15_anonlv;
    bit         k16_anonbit;
  endclass

endpackage

module ktop;
  Kpkg::Holder78 h;
  initial h = new();
endmodule
