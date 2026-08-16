// r10uvm77 VERIFIER ARM x3 — RECEIVER KINDS the implementer's grid never
// filled: `super.`, a CALL-EXPRESSION receiver, a chained parens-less step,
// and a static `::` receiver (buvm1's boundary, measured for breach only).
//
// `superRoot11` keeps site 2 off `super.`, but NOTHING in the patch mentions
// `super.` at site 3 (whose only guard is `recv0.kind == NamedValue`) or at
// site 1 (whose only root guard is the literal `dots[0] != "this"` — "super"
// is not "this").  This arm asks whether that hole is reachable.
class x3base;
  int bp;
  function int bmeth();
    return 1;
  endfunction
endclass

class x3d extends x3base;
  int dp;
  function int f();
    int r;
    r = super.bmeth;          // (1) SUPER-rooted, PARENS-LESS
    r = r + super.bmeth();    // (2) super-rooted, parens-ful control
    r = r + super.bp;         // (3) super-rooted plain property control
    return r;
  endfunction
  static function int smeth();
    return 2;
  endfunction
endclass

module top77x3;
  int r;
  x3d o;
  process p;
  initial begin
    o = new();
    r = o.f();
    r = r + x3d::smeth;              // (4) STATIC `::` receiver, parens-less
    r = r + x3d::smeth();            // (5) static `::`, parens-ful control
    p = process::self();
    r = r + int'(p.status);          // (6) parens-less step inside a CAST
    $display("%0d", r);
  end
endmodule
