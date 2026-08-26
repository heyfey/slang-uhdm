// v159 VERIFIER ARM D — CROSS-PACKAGE ALIASING and IMPORT SPELLINGS.
// pkgImportParamTs159 is keyed on the slang ParameterSymbol, which is SHARED by
// every wildcard import of the same package parameter.  Two packages each
// materialise the SAME parameter and each hosts a class that folds it; a third
// spelling (an EXPLICIT single-name import) and a RE-EXPORT are also scored.
// MEASUREMENT ONLY.
package vq159d_pkg;
  parameter int       VD_W    = 4;
  parameter bit [VD_W-1:0] VD_R = 4'd9;   // a RANGED import whose range reads
                                          // another imported parameter
  parameter int       VD_A    = 101;
  parameter int       VD_B    = 102;
  parameter int       VD_C    = VD_A + 1; // a parameter defaulting to another
endpackage

// FIRST importer
package vp159d1_pkg;
  import vq159d_pkg::*;
  class vc159d1;
    int r;
    function void d1();
      r = VD_A + 1;
      r = VD_R + 1;
      r = VD_C + 1;
      r = VD_W + 1;
    endfunction
  endclass
endpackage

// SECOND importer of the SAME parameters — emitted later, so it is the one that
// wins the symbol-keyed map if the map is the last writer.
package vp159d2_pkg;
  import vq159d_pkg::*;
  class vc159d2;
    int r;
    function void d2();
      r = VD_A + 1;
      r = VD_R + 1;
      r = VD_C + 1;
      r = VD_W + 1;
    endfunction
  endclass
endpackage

// EXPLICIT single-name import (not a wildcard)
package vp159d3_pkg;
  import vq159d_pkg::VD_B;
  class vc159d3;
    int r;
    function void d3();
      r = VD_B + 1;
    endfunction
  endclass
endpackage

module vm159d;
  import vp159d1_pkg::*;
  import vp159d2_pkg::*;
  import vp159d3_pkg::*;
  vc159d1 h1;
  vc159d2 h2;
  vc159d3 h3;
  initial begin
    h1 = new(); h2 = new(); h3 = new();
    h1.d1(); h2.d2(); h3.d3();
  end
endmodule
