// r10v195 arm A — the EXPLICIT (non-wildcard) import of a SUBROUTINE into a
// PACKAGE.  Surelog's CompileHelper::importPackage clones on `inPackage`
// ALONE (src/DesignCompile/CompileHelper.cpp:315-327); `object_name` only
// FILTERS which member is imported.  So `import P::f;` into a package clones
// `f` exactly as `import P::*;` does — a face the implementer's arm D does not
// reach (its explicit import names a CLASS, so the task_func loop skips every
// function).  MEASUREMENT ONLY.
package den195v;
  function void trowel195v();
    process tr_p195v;
    string tr_s195v;
    tr_s195v = "a";
  endfunction
  task mallet195v(int mIn195v = 0);
    process ma_p195v;
    string ma_s195v;
    ma_s195v = "b";
  endtask
  class Auger195v;
    function void bit195v();
      process au_p195v;
      string au_s195v;
      au_s195v = "c";
    endfunction
  endclass
endpackage
package burrow195v;
  import den195v::trowel195v;   // EXPLICIT import of a FREE FUNCTION
  import den195v::mallet195v;   // EXPLICIT import of a TASK
  class Vole195v;
    function void run195v();
      int vr195v;
      vr195v = 0;
    endfunction
  endclass
endpackage
