// r10uvm154 arm B — the VALUE SPELLINGS, one enum per spelling, all under the
// same `bit [31:0]` typedef base the head has.  The first five FIRE
// (§ enumWrittenNegDecLit154); the last five ABSTAIN and must stay pristine —
// golden's answer for each abstention is recorded in README §6 so the next
// pass over this surface starts from a measurement, not a guess.
package pk_b154;
   typedef bit [31:0] w32_t;

   // FIRES
   typedef enum w32_t { fp_plain  = -1        , fp_z = 21 } fire_plain_e;
   typedef enum w32_t { fp_paren  = -(2)      , fq_z = 22 } fire_paren_e;
   typedef enum w32_t { fp_space  = - 3       , fr_z = 23 } fire_space_e;
   typedef enum w32_t { fp_zero   = -0        , fs_z = 24 } fire_zero_e;
   typedef enum w32_t { fp_wide   = -4294967296, ft_z = 25 } fire_wide_e;

   // ABSTAINS — a SIZED or BASED operand, a reference, an inner expression,
   // a bitwise complement, a bare subtraction: all different Surelog cells.
   typedef enum w32_t { ab_sized  = -32'd3    , ba_z = 31 } abst_sized_e;
   typedef enum w32_t { ab_unsz   = -'d4      , bb_z = 32 } abst_unsized_e;
   typedef enum w32_t { ab_double = -(-5)     , bc_z = 33 } abst_double_e;
   typedef enum w32_t { ab_sub    = 1-2       , bd_z = 34 } abst_sub_e;
   typedef enum w32_t { ab_not    = ~0        , be_z = 35 } abst_not_e;
endpackage

module top_b154;
   pk_b154::fire_plain_e   a1;
   pk_b154::fire_paren_e   a2;
   pk_b154::fire_space_e   a3;
   pk_b154::fire_zero_e    a4;
   pk_b154::fire_wide_e    a5;
   pk_b154::abst_sized_e   b1;
   pk_b154::abst_unsized_e b2;
   pk_b154::abst_double_e  b3;
   pk_b154::abst_sub_e     b4;
   pk_b154::abst_not_e     b5;
   initial begin a1 = pk_b154::fp_plain; b1 = pk_b154::ab_sized; end
endmodule
