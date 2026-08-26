// r10uvm156 — MECHANISM grid for the NAME on a CLASS-HANDLE FUNCTION-RETURN
// class_typespec.  MEASUREMENT ONLY; golden = Surelog, LHS is always golden.
// Axis: HOME of the returned class x HOME of the enclosing scope.

package pw156;                       // the "far" package (the uvm_pkg analogue)
  class wrapA156;
    function int f(); return 1; endfunction
  endclass
  class wrapB156;
  endclass
  typedef wrapA156 wrapTdA156;
endpackage

class unitCls156;                    // a $unit class
endclass

import pw156::*;

class unitHome156;                   // ENCLOSING: a $unit class
  function wrapA156 r_far();            return null; endfunction // far pkg, wildcard import
  function pw156::wrapB156 r_scoped();  return null; endfunction // far pkg, WRITTEN scoped
  function unitCls156 r_unit();         return null; endfunction // $unit class
  function unitHome156 r_self();        return null; endfunction // the class itself
endclass

package ph156;                       // ENCLOSING: a package
  import pw156::*;
  class sib156;
  endclass
  class pkgHome156;
    function sib156      r_sib();        return null; endfunction // SAME package
    function wrapA156    r_far();        return null; endfunction // far pkg, imported
    function pw156::wrapB156 r_scoped(); return null; endfunction
    function pkgHome156  r_self();       return null; endfunction
    extern function sib156   r_oob_sib();
    extern function wrapA156 r_oob_far();
    class inner156;
    endclass
    function inner156 r_nested();        return null; endfunction // NESTED class
  endclass
  function sib156   pf_sib();  return null; endfunction           // package FREE function
  function wrapA156 pf_far();  return null; endfunction
  function pkgHome156::inner156 pf_nested(); return null; endfunction
  function sib156   pkgHome156::r_oob_sib(); return null; endfunction   // OUT-OF-BODY
  function wrapA156 pkgHome156::r_oob_far(); return null; endfunction
endpackage

package phb156;                      // ENCLOSING: another package importing ph156
  import ph156::*;
  function sib156 obf(); return null; endfunction
  function ph156::sib156 obfs(); return null; endfunction
endpackage

module mod156;                       // ENCLOSING: a module
  import pw156::*;
  import ph156::*;
  class modCls156;
  endclass
  class modHome156;
    function modCls156  r_mod();  return null; endfunction   // same module
    function wrapA156   r_far();  return null; endfunction
    function unitCls156 r_unit(); return null; endfunction   // a $unit class
    function sib156     r_pkg();  return null; endfunction
  endclass
  function modCls156  mf_mod();  return null; endfunction    // module FREE function
  function wrapA156   mf_far();  return null; endfunction
  function unitCls156 mf_unit(); return null; endfunction
  modHome156 h156;
  initial begin
    h156 = new();
  end
endmodule

program prg156;                      // ENCLOSING: a program
  import pw156::*;
  class prgCls156;
  endclass
  class prgHome156;
    function prgCls156  r_prg();  return null; endfunction
    function wrapA156   r_far();  return null; endfunction
    function unitCls156 r_unit(); return null; endfunction
  endclass
  function wrapA156 gf_far(); return null; endfunction
  initial begin end
endprogram

interface if156;                     // ENCLOSING: an interface
  import pw156::*;
  class ifCls156;
  endclass
  class ifHome156;
    function ifCls156   r_if();   return null; endfunction
    function wrapA156   r_far();  return null; endfunction
    function unitCls156 r_unit(); return null; endfunction
  endclass
  function wrapA156 iff_far(); return null; endfunction
endinterface
