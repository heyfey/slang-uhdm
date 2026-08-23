// r10v113 / v113_ord.sv — THE AWAY HUNT.  Surelog's getTaskFunc walk is
// single-pass, so the question this arm asks is whether the PACKAGE free
// subroutine has to be written ABOVE the class for golden to find it.  If
// golden binds NOTHING while a package function of the name exists, the
// widened fall-back would bind it and that is an AWAY-GOLDEN.
package sord;

  // ---- class FIRST, package free function AFTER it ----
  class Early;
    function int upper(); return Latch(11); endfunction    // Latch declared below, in BOTH scopes
    function int Latch(int k); return k + 100; endfunction
    function int lower(); return Latch(12); endfunction
    function int plain(); return Trough(13); endfunction   // no method of this name at all
  endclass

  function automatic int Latch(int k); return k + 1; endfunction
  function automatic int Trough(int k); return k + 2; endfunction

  // ---- an EXTERN prototype declared BELOW the caller ----
  class ProtoLate;
    function int caller(); return Gasket(14); endfunction
    extern function int Gasket(int k);
  endclass
  function int ProtoLate::Gasket(int k); return k + 110; endfunction
  function automatic int Gasket(int k); return k + 3; endfunction

  // ---- a PURE VIRTUAL prototype below the caller ----
  virtual class PureLate;
    function int caller(); return Sprocket(15); endfunction
    pure virtual function int Sprocket(int k);
  endclass
  function automatic int Sprocket(int k); return k + 4; endfunction

  // ---- a VIRTUAL method below the caller ----
  class VirtLate;
    function int caller(); return Ratchet(16); endfunction
    virtual function int Ratchet(int k); return k + 120; endfunction
  endclass
  function automatic int Ratchet(int k); return k + 5; endfunction

endpackage

package sord2;
  // the same collision but with the free function ABOVE the class, as a
  // face-matched control for every cell above.
  function automatic int Latch2(int k); return k + 1; endfunction
  function automatic int Gasket2(int k); return k + 3; endfunction
  class Early2;
    function int upper(); return Latch2(11); endfunction
    function int Latch2(int k); return k + 100; endfunction
    function int lower(); return Latch2(12); endfunction
  endclass
  class ProtoLate2;
    function int caller(); return Gasket2(14); endfunction
    extern function int Gasket2(int k);
  endclass
  function int ProtoLate2::Gasket2(int k); return k + 110; endfunction
endpackage

module tb_ord;
  import sord::*; import sord2::*;
  Early e; VirtLate v; ProtoLate p; Early2 e2; ProtoLate2 p2;
  initial begin e = new(); v = new(); p = new(); e2 = new(); p2 = new(); end
endmodule
