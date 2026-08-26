// r10v154 arm D — THE THREE LISTING KINDS IN ONE COMPILATION.
//
// The sharpest single-file statement of the rule the shipped code needs.  One
// source, one Surelog run, three homes, the same two written faces (`-0` and
// LEADING ZEROS -- the only two where the raw digits are not the canonical
// spelling of the value, and therefore the only two that can see the view
// discriminator at all).
//
// GOLDEN, measured (vpiDecompile, in listing order):
//
//   $unit    GU_ZERO / GU_LEAD :  `0`            /  `-7`          ONE listing, FOLDED
//   package  SP_ZERO / SP_LEAD :  `-0` then `0`  /  `-007` then `-7`   TWO listings
//   module   MM_ZERO / MM_LEAD :  `-0`           /  `-007`        ONE listing, WRITTEN
//
// The `$unit` row is § unitArith's rule: the compilation unit is compiled
// before any module and elaborated LIKE A TOP PACKAGE, so its single listing IS
// the top one.  A module -- also single-listing -- is not.
//
// The shipped first cut discriminated on `pkgTopEmit` alone and gave `$unit`
// the WRITTEN spelling: AWAY-GOLDEN=2 here, both cells pristine-RIGHT.  With
// `pkgTopEmit || unitEnum9` this arm scores AWAY-GOLDEN=0 TO-GOLDEN=4
// still-right=11, and the package and module rows are untouched either way --
// which is what makes it a fix and not a trade.
typedef enum int { GU_ZERO = -0, GU_LEAD = -007, GU_TAIL = 4 } gu_face_t;
package sidepkg;
  typedef enum int { SP_ZERO = -0, SP_LEAD = -007, SP_TAIL = 4 } sp_face_t;
endpackage
module dut_multi;
  import sidepkg::*;
  typedef enum int { MM_ZERO = -0, MM_LEAD = -007, MM_TAIL = 4 } mm_face_t;
  gu_face_t g; sp_face_t s; mm_face_t m;
  initial begin g = GU_ZERO; s = SP_ZERO; m = MM_ZERO; end
endmodule
