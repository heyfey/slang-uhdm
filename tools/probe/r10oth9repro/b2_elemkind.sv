// r10oth9 arm b2 — EVERY ELEMENT KIND THAT REACHES THE ARM, signed and
// unsigned, class twin and module twin.
//
// The exporter arm this pass edits fires for a PredefinedIntegerType element
// (`et->getCanonicalType().kind == SymbolKind::PredefinedIntegerType`, grep
// "A PREDEFINED-INTEGER element takes the matching integer"), so the atoms are
// the fire set and bit/logic/reg are the CONTROL set that must reach the arm by
// a different path (the write-phase mint, grep "An ELEMENT type with no shared
// alias").  Both sets are here on purpose: a law written for the atoms must be
// measured against the scalars it does NOT own.
//
// SIGNEDNESS FACTS (LRM 6.11): byte/shortint/int/longint/integer/time are
// SIGNED by default with no keyword written; bit/logic/reg and packed vectors of
// them are UNSIGNED by default.  `time` is the odd one — it is a 64-bit
// UNSIGNED atom, so it is a NEGATIVE control inside the atom set.
//
// ONE DECLARATION PER LINE: the line number is the cell id.
class ec;
  rand byte              d01_byte[];
  rand byte unsigned     d02_byteu[];
  rand byte signed       d03_bytes[];
  rand int               d04_int[];
  rand int unsigned      d05_intu[];
  rand shortint          d06_shortint[];
  rand shortint unsigned d07_shortintu[];
  rand longint           d08_longint[];
  rand longint unsigned  d09_longintu[];
  rand integer           d10_integer[];
  rand integer unsigned  d11_integeru[];
  rand time              d12_time[];
  rand bit               d13_bit[];
  rand bit signed        d14_bits[];
  rand logic             d15_logic[];
  rand logic signed      d16_logics[];
  rand reg               d17_reg[];
  rand reg signed        d18_regs[];
  rand bit [7:0]         d19_vec[];
  rand bit signed [7:0]  d20_vecs[];
  rand logic signed [15:0] d21_lvecs[];
endclass

module b2_top;
  byte                   e01_byte[];
  byte unsigned          e02_byteu[];
  byte signed            e03_bytes[];
  int                    e04_int[];
  int unsigned           e05_intu[];
  shortint               e06_shortint[];
  shortint unsigned      e07_shortintu[];
  longint                e08_longint[];
  longint unsigned       e09_longintu[];
  integer                e10_integer[];
  integer unsigned       e11_integeru[];
  time                   e12_time[];
  bit                    e13_bit[];
  bit signed             e14_bits[];
  logic                  e15_logic[];
  logic signed           e16_logics[];
  reg                    e17_reg[];
  reg signed             e18_regs[];
  bit [7:0]              e19_vec[];
  bit signed [7:0]       e20_vecs[];
  logic signed [15:0]    e21_lvecs[];
  ec h;
  initial h = new();
endmodule
