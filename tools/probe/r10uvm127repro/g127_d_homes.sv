// r10uvm127 grid D — THE HOME FENCE.  Only a PACKAGE-level function/task
// declaration is compiled with Reduce::Yes (Surelog CompilePackage.cpp:212-217);
// CompileModule.cpp:776-784 and CompileFileContent.cpp:96-98 hardcode
// Reduce::No, so a class living in a MODULE or at $unit scope takes NOTHING —
// out-of-body definition or not.  Callees are DPI-C imports so the calls
// survive.  MEASUREMENT ONLY.
import "DPI-C" function int unitBlend(string cusp, int lode);

function automatic int unitCaller(string cusp, int lode);
  return unitBlend(cusp, lode);                 // bare ($unit home)
endfunction

class Aperture;
  extern function int unitOob(string cusp, int lode);
endclass

function int Aperture::unitOob(string cusp, int lode);
  return unitBlend(cusp, lode);                 // bare ($unit home)
endfunction

module Kestrel_home;
  import "DPI-C" function int modBlend(string cusp, int lode);

  function automatic int modCaller(string cusp, int lode);
    return modBlend(cusp, lode);                // bare (module home)
  endfunction

  class Gimbal;
    extern function int modOob(string cusp, int lode);
  endclass

  function int Gimbal::modOob(string cusp, int lode);
    return modBlend(cusp, lode);                // bare (module home)
  endfunction

  int got;
  initial got = modCaller("m", 2);
endmodule

package Obsidian;
  import "DPI-C" function int pkgBlend(string cusp, int lode);

  function automatic int pkgCaller(string cusp, int lode);
    return pkgBlend(cusp, lode);                // stamp (POSITIVE control)
  endfunction

  class Trammel;
    extern function int pkgOob(string cusp, int lode);
  endclass

  function int Trammel::pkgOob(string cusp, int lode);
    return pkgBlend(cusp, lode);                // stamp (POSITIVE control)
  endfunction
endpackage

module Obsidian_top;
  import Obsidian::*;
  int got;
  initial got = pkgCaller("p", 1);
endmodule
