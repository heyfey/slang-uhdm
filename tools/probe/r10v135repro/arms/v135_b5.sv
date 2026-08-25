// r10v135 (VERIFIER) ARM b5 — TYPE PARAMETERS and NON-PACKAGE class homes.
// (a) a CLASS-scope type parameter used as an index inside that class's
//     out-of-body method; (b) a MODULE-scope type parameter; (c) a class
//     declared in the MODULE itself; (d) a $unit-scope class used from a
//     module (a package may not reference a compilation-unit item).
class unitAlfaCls5;
  int uv;
endclass

package pkgParmBravo5;
  class dfltKeyCls5;
    int dv;
  endclass
  class parmCharlie5 #(type TKEY5 = dfltKeyCls5);
    extern function void useDelta5();
  endclass
  function void parmCharlie5::useDelta5();
    bit p01ClsTypeParam5 [TKEY5];         // a CLASS-scope type parameter
    bit p06DfltCls5      [dfltKeyCls5];   // the package class itself
    p01ClsTypeParam5.delete();
    p06DfltCls5.delete();
  endfunction

  class echoHost5;
    extern function void foxtrot5();
  endclass
  function void echoHost5::foxtrot5();
    bit p03PkgAgain5 [dfltKeyCls5];
    p03PkgAgain5.delete();
  endfunction
endpackage

module topParmGolf5 #(parameter type MKEY5 = unitAlfaCls5);
  import pkgParmBravo5::*;
  bit p04ModTypeParam5 [MKEY5];        // a MODULE-scope type parameter
  class modHotelCls5;                  // a class declared in the MODULE
    int mv;
  endclass
  bit p05ModCls5 [modHotelCls5];
  bit p02UnitCls5 [unitAlfaCls5];      // a $unit-scope class name
  parmCharlie5 #(dfltKeyCls5) pIndia5;
  echoHost5 eJuliett5;
  initial begin
    pIndia5 = new();
    pIndia5.useDelta5();
    eJuliett5 = new();
    eJuliett5.foxtrot5();
  end
endmodule
