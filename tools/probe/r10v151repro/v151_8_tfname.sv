// r10v151 (VERIFIER) arm 8 — THE `getTaskFunc(name)` BRANCH.  Surelog's
// degenerate road looks the RECEIVER's name up as a subroutine
// (`CompileHelper.cpp:4239`) before falling out at `:4316`, so a receiver whose
// base name also names a FUNCTION gets `vpiFunction` resolved and one that
// names a TASK becomes a `task_call` outright.  Both are pristine-WRONG and
// stay wrong; this arm measures WHICH.  MEASUREMENT ONLY.
package Tpk8;
  function automatic int fname8(int a8); return a8; endfunction
  task automatic tname8(int b8); endtask
  class Coll8;
    int fname8[$];        // shares its name with the package FUNCTION
    int tname8[$];        // shares its name with the package TASK
    int plain8[$];        // the control
    task shoot8;
      fname8.sort() with ( item );
      tname8.sort() with ( item );
      plain8.sort() with ( item );
      fname8.unique();
      tname8.unique();
      plain8.unique();
    endtask
  endclass
endpackage
