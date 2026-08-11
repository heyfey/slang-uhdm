// r10oth8 arm a1 — the CLASS-PROPERTY grid for `vpiSigned` on an array_var.
// One property per cell; the cell id is the property NAME's `aNN_` prefix so
// the extractor can find each array_var by name and list its OWN-DEPTH fields.
// The witness shape is a01 (SVSwitch Packet.sv:23 `rand byte data[];`).
//
// SIGNEDNESS FACTS THIS GRID RESTS ON (SV LRM 6.11): byte/shortint/int/longint
// /integer are SIGNED BY DEFAULT, with no `signed` keyword written; bit/logic
// and any packed vector of them are UNSIGNED by default.  A census that greps
// for the literal keyword `signed` therefore returns ~zero and proves nothing.
class ac;
  // -- dynamic, SIGNED-by-default element, `rand` (THE WITNESS)
  rand byte              a01_dyn_byte[];
  // -- dynamic, signed element, NO `rand`
  byte                   a02_dyn_byte_norand[];
  // -- dynamic, element made UNSIGNED explicitly (must-not-move control)
  rand byte unsigned     a03_dyn_byteu[];
  // -- dynamic, `bit` / `logic`: unsigned by default (must-not-move controls)
  rand bit               a04_dyn_bit[];
  rand logic             a05_dyn_logic[];
  // -- the other signed-by-default integer kinds; the law must NOT key on the
  //    literal `signed` keyword
  rand int               a06_dyn_int[];
  rand shortint          a07_dyn_shortint[];
  rand longint           a08_dyn_longint[];
  rand integer           a09_dyn_integer[];
  // -- QUEUE and ASSOC: the SAME exporter arm serves all three kinds
  rand byte              a10_q_byte[$];
  rand byte              a11_as_byte[string];
  // -- FIXED-size: the boundary of `leadingUnsized`
  rand byte              a12_fix_byte[4];
  // -- explicit keywords, both directions
  rand byte signed       a13_dyn_bytes[];
  rand int unsigned      a14_dyn_intu[];
  // -- packed-vector elements (unsigned by default; signed on request)
  rand bit [7:0]         a15_dyn_vec[];
  rand bit signed [7:0]  a16_dyn_vecs[];
  // -- 2-D: fixed OUTER, dynamic inner, and dynamic OUTER, fixed inner
  rand byte              a17_fix_dyn[4][];
  rand byte              a18_dyn_fix[][4];
  // -- a queue and an assoc of a signed non-byte kind, to separate KIND from
  //    ARRAY-KIND
  rand int               a19_q_int[$];
  rand int               a20_as_int[string];
  // -- non-integral elements, so an over-wide law shows up here.  NOT `rand`:
  //    slang rejects `rand string x[]` / `rand real x[]` outright ("not a valid
  //    type for a 'rand' property"), which is the LRM rule, so the cells would
  //    otherwise make the whole arm unparseable on our side only.
  string                 a21_dyn_string[];
  real                   a22_dyn_real[];
endclass

module a1_top;
  ac h;
  initial h = new();
endmodule
