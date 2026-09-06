// r10uvm169 arm D — THE NEGATIVE HOMES: a MODULE function, a $unit function
// and a module-level wildcard import.  MEASUREMENT ONLY.
//
// CompileModule.cpp:726-768 and CompileFileContent.cpp compile module and
// $unit subroutine bodies with a hardcoded `Reduce::No`, and a module's
// `import p::*` produces NO clone listing at all — a module is not a package.
// Every cell here must be BYTE-IDENTICAL on the two binaries.
package p169hd;
  parameter int kd169 = 11;
  function int f_pkgd169(); return kd169; endfunction
endpackage

function int f_unit169();
  return p169hd::kd169;
endfunction

module g169_d_scopes;
  import p169hd::*;
  parameter int mp169 = 12;
  localparam int ml169 = 13;
  function int f_mod169();    return mp169;  endfunction
  function int f_modloc169(); return ml169;  endfunction
  function int f_modpkg169(); return kd169;  endfunction
  int d_i;
  initial d_i = f_mod169() + f_modloc169() + f_modpkg169() + f_pkgd169() +
                f_unit169();
endmodule
