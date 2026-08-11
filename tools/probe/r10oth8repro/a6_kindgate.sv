// r10oth8 arm a6 — the KIND-WHITELIST arm.  a3/a4/a5 fixed the predicate on
// "as written", and this arm pins the KIND half of it: golden gave an inline
// `struct packed signed` NO `vpiSigned` (a5 d09/e09) and an inline anonymous
// `enum` none either (a5 d01/e01), so the rule cannot be "the written type is
// signed" alone — it has to name the kinds.  These are the kinds a whitelist of
// {integer atom, bit/logic/reg scalar, packed vector} could still get wrong.
// Class half `f*`, module half `g*`, one Surelog run.
class fc;
  rand bit signed        f01_dyn_bitsigned[];   // ScalarType, `signed` written
  rand logic signed      f02_dyn_logicsigned[];
  rand reg signed        f03_dyn_regsigned[];
  rand time              f04_dyn_time[];        // 64-bit UNSIGNED atom
  rand bit               f05_dyn_bit[];         // ScalarType, unsigned
  rand byte              f06_q2_byte[$:7];      // BOUNDED queue
  rand struct { byte a; } f07_dyn_unpstruct[];   // UNPACKED struct, inline
endclass

module a6_top;
  bit signed        g01_dyn_bitsigned[];
  logic signed      g02_dyn_logicsigned[];
  reg signed        g03_dyn_regsigned[];
  time              g04_dyn_time[];
  bit               g05_dyn_bit[];
  byte              g06_q2_byte[$:7];
  struct { byte a; } g07_dyn_unpstruct[];
  fc fh;
  initial fh = new();
endmodule
