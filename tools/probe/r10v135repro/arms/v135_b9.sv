// r10v135 (VERIFIER) ARM b9 — R-EXPLICITIMPORT CONTROL.  The § 130 family
// (`new[<local>]`) under an EXPLICIT SINGLE-NAME import.  If PRISTINE misses the
// wire here too, the module-set gate is the shared pool's, not this pass's.
package pkgExpAlfa9;
  class ctlOwnBravo9;
    extern function void ctlCharlie9();
  endclass
  function void ctlOwnBravo9::ctlCharlie9();
    int dynDelta9[];
    int ctlSizeEcho9;
    ctlSizeEcho9 = 5;
    dynDelta9 = new[ctlSizeEcho9];
    dynDelta9.delete();
  endfunction
endpackage

module topExpFoxtrot9;
  import pkgExpAlfa9::ctlOwnBravo9;      // EXPLICIT single-name import
  ctlOwnBravo9 oGolf9;
  initial begin
    oGolf9 = new();
    oGolf9.ctlCharlie9();
  end
endmodule
