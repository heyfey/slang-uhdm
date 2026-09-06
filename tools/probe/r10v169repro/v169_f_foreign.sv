// r10v169 arm F — FOREIGN-PACKAGE parameters and a CHAINED import.
// MEASUREMENT ONLY.  Surelog's getValue walks the COMPILED component's own
// getParam_assigns(), so a parameter that lives in a THIRD package is a
// different arm from the home's own; and a wildcard import is not re-exported
// (LRM 26.3), so a clone must not be re-cloned one package further.
package p169fx;
  parameter int    kx169 = 41;
  parameter string sx169 = "eff";
endpackage

package p169hf;
  parameter int kf169 = 8;
  function int f_qual169();  return p169fx::kx169; endfunction  // QUALIFIED foreign
  function int f_ownf169();  return kf169;         endfunction  // control
endpackage

package p169hf2;
  import p169fx::*;
  function int    f_wild169();  return kx169; endfunction       // WILDCARD-visible foreign
  function string f_wilds169(); return sx169; endfunction
endpackage

package p169if;
  import p169hf::*;
  import p169hf2::*;
  parameter int ownf169 = 2;
  function int f_ownif169(); return ownf169; endfunction
endpackage

package p169jf;                 // CHAINED: imports the importer, not the home
  import p169if::*;
  parameter int ownj169 = 3;
  function int f_ownjf169(); return ownj169; endfunction
endpackage

module v169_f_foreign;
  import p169hf::*;
  import p169hf2::*;
  import p169if::*;
  import p169jf::*;
  int f_i; string f_s;
  initial begin
    f_i = f_qual169() + f_ownf169() + f_wild169() + f_ownif169() + f_ownjf169();
    f_s = f_wilds169();
  end
endmodule
