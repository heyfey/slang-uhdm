// r10v135 (VERIFIER) ARM b6 — R-MULTI CONTROL.  The SAME three-top shape as b4,
// but the hoisted name comes from § newArrayArgHoistNet130 (a dynamic array's
// `new[<local>]` size argument), a family the PRISTINE binary already hoists.
// If PRISTINE spreads its name to the non-calling importer, R-MULTI is the
// SHARED POOL's pre-existing residue and not this pass's doing.
package pkgCtlAlfa6;
  class ctlOwnerBravo6;
    extern function void ctlCharlie6();
  endclass
  function void ctlOwnerBravo6::ctlCharlie6();
    int dynDelta6[];
    int ctlSizeEcho6;
    ctlSizeEcho6 = 4;
    dynDelta6 = new[ctlSizeEcho6];
    dynDelta6.delete();
  endfunction
endpackage

module topOneFoxtrot6;               // imports AND calls
  import pkgCtlAlfa6::*;
  ctlOwnerBravo6 oGolf6;
  initial begin
    oGolf6 = new();
    oGolf6.ctlCharlie6();
  end
endmodule

module topTwoHotel6;                 // imports, never calls
  import pkgCtlAlfa6::*;
  int hv6;
  initial hv6 = 1;
endmodule
