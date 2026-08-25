// r10uvm135 — GRID ARM a3: THE OWNER / MULTIPLICITY GRID (R-MULTI, inherited
// from § oobRefVarLocalHoistNet107 — recorded, not fixed by this pass).
// MEASUREMENT ONLY.  ONE index name written ONCE, in an out-of-body method of a
// package class; THREE modules see the package: two TOPS that import it at file
// scope and the CHILD one of them instantiates.
package pkgMultiZeta135;
  class keyAbcCls135;
    int kv;
  endclass
  class carrierDefCls135;
    extern function void multiGhiFn135();
  endclass
  function void carrierDefCls135::multiGhiFn135();
    bit multiJklMap135 [keyAbcCls135];
    multiJklMap135.delete();
  endfunction

  // THE CONTROL, and it is a DIFFERENT FAMILY: § newArrayArgHoistNet130's
  // dynamic-array `new[...]` size argument.  The PRISTINE binary already spreads
  // this name over every importing module while golden mints it in ONE — so an
  // arm that shows the same spread for `keyAbcCls135` is showing the SHARED
  // POOL's residue R-MULTI (uvm107's), not anything this pass added.
  class ctlPqsCls135;
    extern function void ctlTuvFn135();
  endclass
  function void ctlPqsCls135::ctlTuvFn135();
    int dynCtlWxy135[];
    int ctlSizeZab135;
    ctlSizeZab135 = 3;
    dynCtlWxy135 = new[ctlSizeZab135];
    dynCtlWxy135.delete();
  endfunction
endpackage

module kidMnoMulti135;
  import pkgMultiZeta135::*;
  carrierDefCls135 hPqrKid135;
  initial begin
    hPqrKid135 = new();
    hPqrKid135.multiGhiFn135();
  end
endmodule

module topStuMulti135;
  import pkgMultiZeta135::*;
  kidMnoMulti135 uVwxKid135();
  initial begin end
endmodule

module topYzaMulti135;
  import pkgMultiZeta135::*;
  initial begin end
endmodule
