// r10v124 arm 4 — the SAME select as an ordinary RVALUE and LVALUE in the SAME
// method as the statement call.  The rvalue/lvalue cells MUST keep their
// selected text; only the statement call's names may move.
package Mill;
  typedef int Skein[$];

  class Bobbin;
    Skein Spindle[string];
    Skein Frame[4];
    int   Plain[string];
    int   Gauge;

    function void weave(string kx, int ix);
      Plain[kx]  = 7;                       // LVALUE with a select
      Gauge      = Plain[kx];               // RVALUE with a select
      Frame[2]   = Spindle[kx];             // both sides selected
      Spindle[kx].push_back(Plain[kx]);     // the STATEMENT CALL + rvalue arg
      Frame[ix].push_back(Gauge);
      Gauge      = Spindle[kx].size();      // EXPRESSION-position call (control)
      Gauge      = Frame[1].size();
      if (Spindle.exists(kx)) Gauge++;
      Spindle[kx].delete();
      Frame[3].delete();
    endfunction
  endclass
endpackage

module Loom;
  Mill::Bobbin bb;
  initial begin
    bb = new();
    bb.weave("warp", 0);
  end
endmodule
