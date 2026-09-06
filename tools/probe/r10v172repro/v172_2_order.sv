// r10v172 arm 2 — THE SEARCH ORDER.  Surelog's getTaskFunc order is
//   (1) the component's own task_funcs, up getParentScope();
//   (2) the component's own FileContents' FILE-LEVEL ($unit) task_funcs;
//   (3) getFuncFromPackage — the IMPORTED packages, transitively;
//   (4) every file's FILE-LEVEL task_funcs.
// The implementer's transcription is (1), (3), (4-as-compilation-units): steps
// 2 and 3 are SWAPPED.  A name that is BOTH a $unit subroutine and an imported
// package subroutine OF THE OTHER KIND therefore picks a DIFFERENT OBJECT KIND
// on the two sides if the order matters.  MEASUREMENT ONLY.
package pv2172;
  task     clash172(); endtask          // the imported PACKAGE side: a TASK
  function int only172(); return 1; endfunction
endpackage

package pv2b172;
  function int clash2172(); return 2; endfunction  // the imported side: a FUNCTION
endpackage

function automatic int clash172();       // the $unit side: a FUNCTION
  return 7;
endfunction

task automatic clash2172();              // the $unit side: a TASK
endtask

package pkgv2172;
  import pv2172::*;
  import pv2b172::*;

  class bagv2172;
    string q172[$];
  endclass

  class cv2172;
    function void probe172();
      bagv2172 clash172;    // v2_01 $unit FUNCTION vs imported-package TASK
      bagv2172 clash2172;   // v2_02 $unit TASK vs imported-package FUNCTION
      bagv2172 only172;     // v2_03 control: only the imported package has it
      clash172  = new(); clash172.q172.push_back("v2_01");
      clash2172 = new(); clash2172.q172.push_back("v2_02");
      only172   = new(); only172.q172.push_back("v2_03");
    endfunction
  endclass
endpackage

module topv2172;
  pkgv2172::cv2172 c172;
  initial begin
    c172 = new();
    c172.probe172();
  end
endmodule
