// r10uvm47 arm t65d — the DISCRIMINATOR between the two rules t65c could not
// separate: "FIRST entry in the listing wins" vs "the PACKAGE MEMBER wins".
//
// t65c showed golden binding `reads_shared`'s ref to `r1::shared_name`@29:7 —
// the package MEMBER — and not to the hoisted out-of-body constructor local
// `r1::shared_name`@37:9 that shares its fullname.  But in t65c the member also
// happens to come FIRST in the source-ordered listing, so the two rules agree
// there.  Here the HOISTED local is declared EARLIER than the member, so the
// rules disagree and golden picks one.
//
// (A law that only ever saw one spelling has an unmeasured half; this is that
// half, made measurable.)
package r2;

  class ooc;
    int p;
    extern function new();
  endclass

  function ooc::new();
    int dup_name = 111;          // HOISTED local — EARLIER line
    p = dup_name;
  endfunction

  int dup_name = 222;            // package MEMBER — LATER line
  int reads_dup = dup_name;      // which one does golden bind?

endpackage

module t65d;
  import r2::*;
  initial $display("%0d", reads_dup);
endmodule
