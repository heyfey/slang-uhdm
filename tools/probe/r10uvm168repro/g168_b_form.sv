// r10uvm168repro/g168_b_form.sv — MEASUREMENT ONLY.
// ARM B: the PARAMETER SIDE.  One enum family, every declaration form the
// parameter itself can take — typed / untyped / retyped, parameter vs
// localparam, and the RHS reached DIRECTLY, THROUGH ANOTHER PARAMETER, through
// a CAST, and through ARITHMETIC.  Cell = the folded constant's vpiConstType.
package welkin_pkg;

  typedef enum { HAVEN_NIL, HAVEN_ONE, HAVEN_PAIR, HAVEN_TRIO } haven_e;
  typedef enum logic [3:0] { GABLE_NIL, GABLE_ONE, GABLE_PAIR } gable_e;
  typedef enum { CINDER_SET = 6, CINDER_NEXT } cinder_e;

  // --- the parameter's own declared type
  parameter haven_e  kb_enumty  = HAVEN_TRIO;   // b01 typed with the enum
  parameter int      kb_intty   = HAVEN_TRIO;   // b02 typed `int`
  parameter integer  kb_integty = HAVEN_TRIO;   // b03 typed `integer`
  parameter logic [7:0] kb_logty = HAVEN_TRIO;  // b04 typed logic vector
  parameter bit [7:0]   kb_bitty = HAVEN_TRIO;  // b05 typed bit vector
  parameter byte     kb_byty    = HAVEN_TRIO;   // b06 typed `byte`
  parameter          kb_untyped = HAVEN_TRIO;   // b07 UNTYPED

  // --- localparam twins of the same three
  localparam haven_e kb_lp_enum = HAVEN_PAIR;   // b08
  localparam int     kb_lp_int  = HAVEN_PAIR;   // b09
  localparam         kb_lp_bare = HAVEN_PAIR;   // b10

  // --- through ANOTHER PARAMETER (one hop, two hops, cross-typed)
  parameter haven_e  kb_hop1    = kb_enumty;    // b11
  parameter haven_e  kb_hop2    = kb_hop1;      // b12
  parameter int      kb_hopint  = kb_enumty;    // b13
  localparam haven_e kb_lp_hop  = kb_enumty;    // b14

  // --- through ARITHMETIC over the enum member (must NOT take the enum form)
  parameter int      kb_plus    = HAVEN_TRIO + 1;   // b15
  parameter int      kb_minus   = HAVEN_TRIO - 1;   // b16
  parameter int      kb_times   = HAVEN_TRIO * 2;   // b17
  parameter int      kb_shift   = HAVEN_TRIO << 1;  // b18
  parameter int      kb_paren   = (HAVEN_TRIO);     // b19 parenthesised, still bare

  // --- through a CAST
  parameter int      kb_castint = int'(HAVEN_TRIO);  // b20
  parameter logic [7:0] kb_castw = 8'(HAVEN_TRIO);   // b21

  // --- the WIDE-BASE enum, same forms
  parameter gable_e  kb_wide    = GABLE_PAIR;   // b22
  parameter int      kb_wideint = GABLE_PAIR;   // b23
  localparam         kb_wbare   = GABLE_PAIR;   // b24

  // --- an EXPLICITLY VALUED member and its auto successor, both homes
  parameter cinder_e kb_expl    = CINDER_SET;   // b25
  parameter cinder_e kb_explnxt = CINDER_NEXT;  // b26

  // --- NEGATIVE CONTROLS: nothing enum-shaped, must not move
  parameter int      kb_plainint = 3;           // b27
  parameter          kb_plainbare = 3;          // b28
  parameter logic [3:0] kb_plainlit = 4'd3;     // b29
  parameter int      kb_plainexpr = 2 + 1;      // b30
  parameter int      kb_plaindiv  = 9 / 3;      // b31 (INT by the divide rule)
  parameter string   kb_plainstr  = "trio";     // b32
  parameter real     kb_plainreal = 3.5;        // b33
  parameter int      kb_hopplain  = kb_plainint;// b34

endpackage

// The SAME parameter forms in a MODULE that imports the package, so the
// materialised-copy path is measured beside the package's own.
module welkin_mod;
  import welkin_pkg::*;
  parameter haven_e  kb_m_enum  = HAVEN_TRIO;   // b41
  parameter int      kb_m_int   = HAVEN_TRIO;   // b42
  localparam haven_e kb_m_lp    = HAVEN_PAIR;   // b43
  localparam         kb_m_bare  = HAVEN_PAIR;   // b44
  parameter gable_e  kb_m_wide  = GABLE_PAIR;   // b45
  localparam int     kb_m_plain = 3;            // b46 negative control
endmodule
