// r10v130repro/v130_b7.sv — VERIFIER ARM b7: the R-MULTI INHERITANCE CONTROL.
// The SAME two-top / three-instance shape as v130_b4.sv, but the hoisted name is
// a `ref` FORMAL — § oobRefVarLocalHoistNet107's OWN population, which the
// PRISTINE binary already hoists.  If the PRISTINE binary spreads that name over
// every importing module while golden mints one wire, then the spread arm b4
// measures is INHERITED from the shared pool and not this pass's.
// MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
package pkRefMult130v;
  class cRefMult130v;
    int dynRefMult130v[];
    extern function void refMultRunner130v(ref int refSpreadTau130v);
  endclass
  function void cRefMult130v::refMultRunner130v(ref int refSpreadTau130v);
    dynRefMult130v = new[2];
    dynRefMult130v[0] = refSpreadTau130v;      // § 107's own family, PRISTINE hoists
  endfunction
endpackage

import pkRefMult130v::*;

module kidRef130v;
  initial begin
    cRefMult130v hKidRef130v;
    int aRef130v;
    hKidRef130v = new();
    aRef130v = 1;
    hKidRef130v.refMultRunner130v(aRef130v);
  end
endmodule

module topAref130v;
  kidRef130v i0ref130v();
  kidRef130v i1ref130v();
  kidRef130v i2ref130v();
endmodule

module topBref130v;
  kidRef130v j0ref130v();
endmodule

module noImportRef130v;
  int untouchedUps130v;
  initial untouchedUps130v = 0;
endmodule
