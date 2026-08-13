// VERIFIER probe v1 — the NON-$ NON-METHOD system subroutine hole.
// `randomize` (scope randomize, IEEE 18.12) is registered by slang via
// addSystemSubroutine (NOT addSystemMethod): isSystemCall()==true, name has NO
// `$`, thisClass()==null, and arguments()[0] is a RANDOMIZED VARIABLE, not a
// receiver.  builtinMethodRecv1's four tests all pass on it.
package pv;
  int pvx;
  int pvy;
  class cv;
    static int svx;
    rand int r;
  endclass
endpackage

module mv;
  int ok;
  int lv;
  initial begin
    // W1 — bare scope randomize, arg0 is a `::`-scoped PACKAGE VARIABLE
    ok = std::randomize(pv::pvx);
    // W2 — same, two args
    ok = std::randomize(pv::pvx, pv::pvy);
    // W3 — arg0 is a `::`-scoped CLASS STATIC
    ok = std::randomize(pv::cv::svx);
    // W4 — control: arg0 unscoped
    ok = std::randomize(lv);
  end
endmodule
