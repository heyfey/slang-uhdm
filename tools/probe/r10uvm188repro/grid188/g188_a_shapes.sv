// r10uvm188 — ARM a: INITIALISER SHAPE x enum BASE, in a package.
// Three bases (none / written vector / typedef name) carry the SAME twelve
// initialiser shapes, so the arm separates "the shape decides" from "the base
// decides".  Every value is distinct (SystemVerilog forbids duplicate enum
// values, and slang rejects the file rather than emitting a partial database).
package ash;
  parameter AshBits = 24;
  typedef bit [AshBits-1 : 0] ash_flag_t;

  // (1) NO base at all
  typedef enum {
    aN_plain  = 99,
    aN_based  = 'h64,
    aN_sized  = 32'h065,
    aN_shl    = 1 << 4,
    aN_shr    = 256 >> 3,
    aN_add    = 3 + 40,
    aN_sub    = 60 - 10,
    aN_mul    = 6 * 11,
    aN_div    = 84 / 1,
    aN_paren  = (2 + 3) * 4,
    aN_nest   = 1 << (2 + 1),
    aN_bshl   = 'h10 << 4,
    aN_zshl   = 8'h1 << 9
  } ash_none_e;

  // (2) a WRITTEN vector base
  typedef enum bit [23:0] {
    aW_plain  = 99,
    aW_based  = 'h64,
    aW_sized  = 24'h065,
    aW_shl    = 1 << 4,
    aW_shr    = 256 >> 3,
    aW_add    = 3 + 40,
    aW_sub    = 60 - 10,
    aW_mul    = 6 * 11,
    aW_div    = 84 / 1,
    aW_paren  = (2 + 3) * 4,
    aW_nest   = 1 << (2 + 1),
    aW_bshl   = 'h10 << 4,
    aW_zshl   = 8'h1 << 9
  } ash_wide_e;

  // (3) a TYPEDEF-NAME base — the head's own shape
  typedef enum ash_flag_t {
    aT_plain  = 99,
    aT_based  = 'h64,
    aT_sized  = 24'h065,
    aT_shl    = 1 << 4,
    aT_shr    = 256 >> 3,
    aT_add    = 3 + 40,
    aT_sub    = 60 - 10,
    aT_mul    = 6 * 11,
    aT_div    = 84 / 1,
    aT_paren  = (2 + 3) * 4,
    aT_nest   = 1 << (2 + 1),
    aT_bshl   = 'h10 << 4,
    aT_zshl   = 8'h1 << 9
  } ash_td_e;
endpackage
module ashm;
  ash::ash_none_e n0; ash::ash_wide_e w0; ash::ash_td_e t0;
  initial begin n0 = ash::aN_shl; w0 = ash::aW_shl; t0 = ash::aT_shl; end
endmodule
