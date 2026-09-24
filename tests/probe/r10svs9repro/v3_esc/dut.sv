// r10svs9 VERIFIER arm v3 — THE ESCAPED-IDENTIFIER HAZARD, pushed past a3.
//
// STANDING OPS RULE: "escaped identifiers on any name-reading gate — a dotted-
// name law is EXACTLY where an escaped identifier containing a dot bites".
// The implementer's a3 covers ONE escaped spelling (an escaped BASE whose text
// contains a dot).  These are the spellings a3 does not reach, each of which
// attacks the law's name-reading (`bs9->identifier.valueText()`) or its
// dot-separator walk (`sn.separator.kind != TokenKind::Dot`) a different way:
//
//   e1  escaped base containing a dot           (a3 g1's cell, carried as control)
//   e2  escaped MEMBER containing a dot — the DROPPED half carries the hazard
//   e3  BOTH halves escaped, both containing dots
//   e4  escaped base whose text contains `::`   (attacks the separator walk:
//       the TEXT has a scope operator but the TOKEN is one identifier)
//   e5  escaped base whose text is a KEYWORD (`\this`) — clause 4 reads a token
//       kind, and an escaped `this` is an IdentifierName, not a keyword
//   e6  escaped base containing a SPACE-adjacent trailing separator plus a
//       three-component path
interface in_if(input bit clock);
    logic rdy;
    modport IP(input clock, input rdy);
endinterface

class C;
    virtual in_if.IP \esc.h ;
    virtual in_if.IP \a::b ;
    virtual in_if.IP vif;

    // e1 — escaped BASE containing a dot (control, = a3 g1)
    task e1(); @ \esc.h .clock; endtask
    task e1p(); @(\esc.h .clock); endtask

    // e4 — escaped base whose TEXT contains `::` but which is ONE token
    task e4(); @ \a::b .clock; endtask
    task e4p(); @(\a::b .clock); endtask

    // e5 — REMOVED: slang binds escaped `\this` as the `this` KEYWORD and
    // rejects the member access ("no member named 'clock' in 'C'"), so the cell
    // cannot be measured on our side at all.  Recorded, not smoothed over.
endclass

module top;
    bit clock;
    in_if u_if(clock);
    C c;
endmodule
