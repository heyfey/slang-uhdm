// r10uvm77 VERIFIER ARM x2 — THE PROBE'S DECLARED BLIND SPOT (residue R5),
// measured rather than asserted.
//
// The probe scans forward from the method-name token past " \t\r\n" ONLY.  A
// COMMENT is not whitespace to it: the first non-space character of `/* c */`
// is `/`, which is not `(`, so the probe reads PARENS-LESS on a call that was
// written WITH parentheses.  The README names this and calls it "unmeasured in
// either corpus".  This arm measures it, and also measures the LINE-comment
// spelling, which the README never mentions at all.
class x2c;
  int p;
  function int meth();
    return 7;
  endfunction
endclass

module top77x2;
  int r;
  x2c o;
  initial begin
    o = new();
    r = o.meth();                 // (1) tight parens-ful — the control
    r = r + o.meth /* c */ ();    // (2) BLOCK comment before the parens
    r = r + o.meth //  c
              ();                 // (3) LINE comment before the parens
    r = r + o.meth /* c */ ;      // (4) block comment, genuinely parens-less
    $display("%0d", r);
  end
endmodule
