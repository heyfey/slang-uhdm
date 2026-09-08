// r10uvm207 arm D — THE EXPLICIT-IMPORT CONTROL.  `import p::f;` names ONE
// subroutine; `CompileHelper::importPackage` clones it too, but § 194's
// committed registry `pkgImportCloneTfs16` is WILDCARD-ONLY, so this arm must
// stay BYTE-IDENTICAL between the two binaries.  It also MEASURES what golden
// does there, so the residue is recorded rather than assumed.
package p207a_n;
  typedef bit [63:0] bt207n;
  typedef struct { bt207n n_min207; bt207n n_max207; int n_stride207; } sn207;
  function automatic int fn207();
    sn207 ln207;
    return int'(ln207.n_min207);
  endfunction
endpackage

package p207b_n;
  import p207a_n::fn207;                  // EXPLICIT, not wildcard
  function automatic int gb207n();
    return fn207();
  endfunction
endpackage

module g207_d_noimport;
  import p207b_n::*;
  int r207n;
  initial r207n = gb207n();
endmodule
