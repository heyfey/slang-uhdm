// r10svs2 VERIFIER ARM w3 — the two remaining ways the TEXT GATE can be fooled.
//  (a) MACRO EXPANSION.  Both gates compare `rawText(expr.sourceRange)` against
//      a name, and rawText walks a macro range back to the DEFINITION site
//      (getFullyOriginalRange).  A call written inside a macro body therefore
//      compares the macro's own spelling, not the expanded one.
//  (b) A DEEP DOTTED RECEIVER (`a.b.size`), where the receiver is itself a
//      member-access expression, so `recv->sourceRange.end()+1` is measured from
//      the END of the whole dotted prefix.
`define SZ_NOPAREN  d.size
`define SZ_PAREN    d.size()
`define F_NOPAREN   zero
`define F_PAREN     zero()

class inner;
  int b[];
endclass

class w3;
  int    d[];
  inner  a;

  function int zero(); return 3; endfunction

  function int f();
    int r;
    r = d.size;            // (1) BASELINE tight, no macro
    r = r + `SZ_NOPAREN;   // (2) parens-less method THROUGH A MACRO
    r = r + `SZ_PAREN;     // (3) parens-ful  method THROUGH A MACRO
    r = r + `F_NOPAREN;    // (4) parens-less receiver-less func THROUGH A MACRO
    r = r + `F_PAREN;      // (5) parens-ful  receiver-less func THROUGH A MACRO
    r = r + a.b.size;      // (6) DEEP dotted receiver, parens-less
    r = r + a.b.size();    // (7) DEEP dotted receiver, parens-ful  (control)
    return r;
  endfunction
endclass

module top;
  w3 o;
  initial begin
    o = new(); o.a = new();
    $display("%0d", o.f());
  end
endmodule
