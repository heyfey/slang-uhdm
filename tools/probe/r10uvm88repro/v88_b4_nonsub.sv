// v88 b4 — POSITIONS THAT ARE NOT A SUBROUTINE BODY.  The gate is a flag set
// only inside emitTaskFuncs' per-subroutine loop, so a class-scope expression
// emitted OUTSIDE that loop is NOT gated.  If golden leaves those bare too, the
// gate is INCOMPLETE (a residue); if golden binds them, pristine==patched here.
package p4;
  const string c4 = "C4";
  int          n4 = 4;
  parameter int P4 = 7;
  class k4;
    string s = c4;                     // PROPERTY INITIALISER
    int    i = n4;                     // PROPERTY INITIALISER
    static string ss = c4;             // STATIC property initialiser
    rand int rv;
    constraint cst4 { rv < n4; }       // CONSTRAINT
    function void deffml(int a = n4);  // DEFAULT FORMAL VALUE
      i = a;
    endfunction
    function void inb4();
      s = c4; i = n4;
      fork begin s = c4; end join_none // FORK body
      assert (i != n4);                // ASSERTION expression
    endfunction
  endclass
endpackage
module topb4;
  p4::k4 h; initial begin h = new(); h.inb4(); end
endmodule
