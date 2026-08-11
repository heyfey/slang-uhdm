// r10oth8 arm a7 — the FIXED-SIZE unpacked array at MODULE scope, which is a
// DIFFERENT exporter function (`UhdmExporter::emitArrayVar`) from the one this
// pass patches, and which carries the SAME `leaf->isSigned()` predicate.  The
// only reason this arm exists is to find out whether that third site over-fires
// on a typedef'd element too, because if it does its reach is far larger than
// the target's (fixed unpacked arrays are everywhere) and it must be RECORDED
// rather than bolted onto this pass — span/predicate widening on a large
// population is this campaign's named over-fire class.
typedef byte  b_t;
typedef int   i_t;
typedef bit [7:0] u8_t;

module a7_top;
  byte   h01_fix_byte[4];      // written signed atom
  b_t    h02_fix_btd[4];       // typedef'd signed byte
  i_t    h03_fix_itd[2][3];    // typedef'd signed int, 2-D
  u8_t   h04_fix_u8td[4];      // typedef'd unsigned vector
  bit signed [7:0] h05_fix_vs[4];
endmodule
