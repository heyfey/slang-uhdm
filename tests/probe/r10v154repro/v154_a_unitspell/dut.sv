// r10v154 arm A — THE BREAK THIS VERIFIER FOUND AND FIXED.
//
// A `$unit`-scope enum has ONE listing, and that listing is the ELABORATED
// (top) one — § unitArith already says the compilation unit is compiled before
// any module and elaborated LIKE A TOP PACKAGE.  So its enum-constant
// decompile takes the FOLDED spelling, not the written one.  The two spellings
// differ for exactly two written faces: `-0` (folds to `0`) and LEADING ZEROS
// (`-007` folds to `-7`).  The shipped first cut discriminated on `pkgTopEmit`
// alone, which is FALSE here, and emitted `-0` / `-007` where golden emits
// `0` / `-7` — pristine-RIGHT -> patched-WRONG on legal SystemVerilog.
//
// Golden (Surelog), measured, one listing per constant:
//   UZ_ZERO  INT:0  / vpiDecompile `0`   / 64
//   UZ_LEAD  INT:-7 / vpiDecompile `-7`  / 64
//   UZ_PLAIN INT:-9 / vpiDecompile `-9`  / 64   (raw == folded: the face that
//                                                cannot see the bug)
typedef enum { UZ_ZERO = -0, UZ_TAILA = 5 }   uz_none_t;
typedef enum int { UZ_LEAD = -007, UZ_TAILB = 6 } uz_int_t;
typedef enum byte { UZ_PLAIN = -9, UZ_TAILC = 7 } uz_byte_t;
typedef enum bit [31:0] { UZ_SEP = -1_0, UZ_TAILD = 8 } uz_bit_t;
module dut_unitspell;
  uz_none_t held_a; uz_int_t held_b; uz_byte_t held_c; uz_bit_t held_d;
  initial begin held_a = UZ_ZERO; held_b = UZ_LEAD; held_c = UZ_PLAIN; held_d = UZ_SEP; end
endmodule
