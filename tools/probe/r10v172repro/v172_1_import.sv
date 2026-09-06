// r10v172 arm 1 — WHERE THE IMPORT IS WRITTEN.  The implementer's search
// collects imports from EVERY enclosing scope; Surelog's getFuncFromPackage
// walks only the COMPONENT's own getAccessPackages().  Each cell writes the
// SAME statement on a local whose spelling is a package subroutine reached by
// an import written at a DIFFERENT scope.  MEASUREMENT ONLY.
package pv1a172;
  function int impa172(); return 1; endfunction
  task     impt172(); endtask
endpackage

package pv1b172;
  function int impb172(); return 2; endfunction
endpackage

package pv1c172;
  function int impc172(); return 3; endfunction
endpackage

package pv1d172;                          // never imported anywhere — control
  function int impd172(); return 4; endfunction
endpackage

package pv1e172;                          // transitively reached: pv1f imports it
  function int impe172(); return 5; endfunction
endpackage

package pv1f172;
  import pv1e172::*;
  function int impf172(); return 6; endfunction
endpackage

import pv1b172::*;                        // $unit-scope wildcard import

// (1) the import sits on the ENCLOSING PACKAGE, the class is inside it
package pkgv1172;
  import pv1a172::*;
  import pv1c172::impc172;                // EXPLICIT (non-wildcard) import
  import pv1f172::*;                      // transitive road to pv1e172

  class bagv1172;
    string q172[$];
  endclass

  class cinpkg172;
    function void probe172();
      bagv1172 impa172;   // v1_01 pkg-scope wildcard import, FUNCTION
      bagv1172 impt172;   // v1_02 pkg-scope wildcard import, TASK
      bagv1172 impb172;   // v1_03 $unit-scope wildcard import
      bagv1172 impc172;   // v1_04 EXPLICIT import
      bagv1172 impd172;   // v1_05 NEVER imported (control: must NOT collapse)
      bagv1172 impe172;   // v1_06 TRANSITIVE (pv1f imports pv1e)
      bagv1172 impf172;   // v1_07 direct wildcard, one level
      impa172 = new(); impa172.q172.push_back("v1_01");
      impt172 = new(); impt172.q172.push_back("v1_02");
      impb172 = new(); impb172.q172.push_back("v1_03");
      impc172 = new(); impc172.q172.push_back("v1_04");
      impd172 = new(); impd172.q172.push_back("v1_05");
      impe172 = new(); impe172.q172.push_back("v1_06");
      impf172 = new(); impf172.q172.push_back("v1_07");
    endfunction
  endclass
endpackage

// (2) the import sits on the ENCLOSING MODULE, the class is inside it
module topv1172;
  import pv1a172::*;
  import pkgv1172::*;

  class cinmod172;
    function void mprobe172();
      bagv1172 impa172;   // v1_08 module-scope wildcard import
      bagv1172 impb172;   // v1_09 $unit-scope wildcard import, class in a module
      impa172 = new(); impa172.q172.push_back("v1_08");
      impb172 = new(); impb172.q172.push_back("v1_09");
    endfunction
  endclass

  // (3) the SAME cells written in a module task, not a class method
  task mtask172();
    bagv1172 impa172;     // v1_10
    bagv1172 impb172;     // v1_11
    impa172 = new(); impa172.q172.push_back("v1_10");
    impb172 = new(); impb172.q172.push_back("v1_11");
  endtask

  cinpkg172 c1172;
  cinmod172 c2172;
  initial begin
    c1172 = new(); c1172.probe172();
    c2172 = new(); c2172.mprobe172();
    mtask172();
  end
endmodule
