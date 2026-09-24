// r10uvm85 arm a2 — the two NEGATIVE-CONTROL call families that share the
// statement position: a USER method on a `this.<member>` receiver (already
// § thisRecvCall11's statement form) and a BARE `this.<method>(...)` (the
// paList_of_arguments arm, named after the METHOD).
module g85a2;
  class inner2;
    int      arr[$];
    int      m;
    function void um2(int a); endfunction
  endclass
  class c2;
    inner2   h;
    int      q[$];
    int      n;
    function void um2(int a); endfunction
    function void f(int k);
      this.h.um2(k);       // L16 USER method, 2-deep  (thisRecvCall11 stmt)
      this.h.um2(3);       // L17 same, literal actual
      this.um2(k);         // L18 BARE this.<user>(arg) — named after METHOD
      this.um2(3);         // L19
      this.q.delete(k);    // L20 positive control in the same body
    endfunction
  endclass
endmodule
