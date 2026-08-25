// r10uvm135 — GRID ARM a4: THE TYPE-PARAMETER AND PARAMETER-SHADOW GRID.
// MEASUREMENT ONLY.  `uvm_pool #(KEY,T)`'s `protected T pool[KEY];` is the
// corpus shape this arm reproduces: an index written as the name of a TYPE
// PARAMETER.  It also re-measures § hoistedNetNeverOverAModuleParam117's
// suppressor for THIS reference kind — a module that already declares the index
// name as a PARAMETER, and one that declares it as a VARIABLE.
package pkgTypeParEta135;
  class poolAlnCls135 #(type KEYBRAVO135 = int, type VALCHARLIE135 = int);
    // A class property indexed by the TYPE PARAMETER (uvm_pool's own shape).
    VALCHARLIE135 propDeltaPool135 [KEYBRAVO135];
    extern function void oobEchoFn135();
  endclass

  function void poolAlnCls135::oobEchoFn135();
    bit oobFoxLocal135 [KEYBRAVO135];      // the TYPE PARAMETER, in an OOB body
    oobFoxLocal135.delete();
  endfunction

  class shadowGolfCls135;
    int gv;
  endclass

  class shadowHotelCls135;
    extern function void oobIndiaFn135();
  endclass

  function void shadowHotelCls135::oobIndiaFn135();
    bit oobJulietMap135 [shadowGolfCls135];
    // THE R-MULTI CONTROL, a DIFFERENT family (§ newArrayArgHoistNet130): the
    // PRISTINE binary already mints this name in every importing module while
    // golden mints it in one.  Any spread this arm shows for an ASSOCIATIVE
    // INDEX name is the shared pool's, not this pass's.
    int dynQuebecCtl135[];
    int ctlRomeoSize135;
    ctlRomeoSize135 = 3;
    dynQuebecCtl135 = new[ctlRomeoSize135];
    dynQuebecCtl135.delete();
    oobJulietMap135.delete();
  endfunction
endpackage

// The name is a PARAMETER here — golden consults the module's value map before
// it mints (UhdmWriter.cpp:3949-3959), so NO wire.
module topKiloParam135;
  import pkgTypeParEta135::*;
  parameter int shadowGolfCls135 = 7;
  poolAlnCls135 #(int, int) hLimaPool135;
  shadowHotelCls135 hMikeShadow135;
  initial begin
    hLimaPool135 = new();
    hMikeShadow135 = new();
    hMikeShadow135.oobIndiaFn135();
  end
endmodule

// The name is nothing at all here — the plain mint.
module topNovemberFree135;
  import pkgTypeParEta135::*;
  shadowHotelCls135 hOscarShadow135;
  poolAlnCls135 #(int, int) hPapaPool135;
  initial begin
    hOscarShadow135 = new();
    hPapaPool135 = new();
    hOscarShadow135.oobIndiaFn135();
  end
endmodule
