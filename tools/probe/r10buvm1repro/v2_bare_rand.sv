// VERIFIER probe v2 — BARE `randomize(...)` (no `std::` qualifier).
// Then the call's OWN syntax has no `::`, so § scopedRootFromStmtSyntax1's
// STATEMENT fallback is the lookup that runs, and it finds the `::` of the
// ARGUMENT — which builtinMethodRecv1 has already mis-labelled the receiver.
package pw;
  int pwx;
  int pwy;
  class cw;
    static int swx;
  endclass
endpackage

module mw;
  int ok;
  int lw;
  initial begin
    ok = randomize(pw::pwx);          // X1 pkg-var arg0, bare randomize
    ok = randomize(pw::cw::swx);      // X2 class-static arg0, bare randomize
    ok = randomize(lw);               // X3 control, unscoped
  end
endmodule
