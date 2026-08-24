// r10v117 (verifier) arm b5 — IS THE PARAMETER-SHADOW MINT NEW, OR § 107's?
// The SAME collision (a hoisted name that the importing module already
// declares as a PARAMETER / a LOCALPARAM / a GENVAR / a VARIABLE) written
// TWICE: once in an OUT-OF-BODY CLASS METHOD (§ oobRefVarLocalHoistNet107 --
// the PRISTINE binary already hoists there) and once in a FREE PACKAGE
// FUNCTION (§ pkgFreeSubRefVarHoistNet117 -- only the PATCHED binary hoists).
// If the pristine binary mints for the OOB cells too, the defect is § 107's
// and this pass only widens it; if it does not, the pass introduced it.
package PkgShadowTwice;

  class OobShadowCls;
    extern function void oobShadowFn();
  endclass

  function void OobShadowCls::oobShadowFn();
    process oobParamName;      // collides with a module PARAMETER
    process oobLocalParamName; // collides with a module LOCALPARAM
    process oobVarName;        // collides with a module VARIABLE (logic reg)
    oobParamName      = process::self();
    oobLocalParamName = process::self();
    oobVarName        = process::self();
  endfunction

  function automatic void freeShadowFn();
    process freeParamName;      // collides with a module PARAMETER
    process freeLocalParamName; // collides with a module LOCALPARAM
    process freeVarName;        // collides with a module VARIABLE
    freeParamName      = process::self();
    freeLocalParamName = process::self();
    freeVarName        = process::self();
  endfunction

endpackage

import PkgShadowTwice::*;
module TopShadowTwice;
  parameter  int oobParamName       = 1;
  parameter  int freeParamName      = 2;
  localparam int oobLocalParamName  = 3;
  localparam int freeLocalParamName = 4;
  logic          oobVarName;
  logic          freeVarName;
  OobShadowCls hs5;
  initial begin
    hs5 = new();
    hs5.oobShadowFn();
    freeShadowFn();
  end
endmodule
