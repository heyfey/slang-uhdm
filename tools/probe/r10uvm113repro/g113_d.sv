// r10uvm113 / g113_d.sv — THE NON-PACKAGE ENCLOSURES (residue R-mod113) and
// the package-order NEGATIVE cell.
//
// (1) `Kpkg` — the package free function is declared BELOW the class.  Golden
//     still binds it from the class method written above the class's own copy:
//     order matters INSIDE the class, not at package level (the class's
//     `getParentScope()` package listing is complete by the time class bodies
//     compile).  This pass reproduces that cell.
//
// (2) `Kmod` — the very same collision with the free function in a MODULE
//     instead of a package.  Golden binds `work@tb_d::mu`; we leave the call
//     unbound, pristine AND patched.  `pkgFreeSubForName72` does walk out to an
//     InstanceBody, but the module's own `task_func` is not yet in `subMap`
//     when a class declared in that module is emitted, so the lookup misses.
//     A MISS, never an AWAY — and it is the residue this pass names, not fixes.
package hb;
  class Kpkg;
    function int upper(); return nu(1); endfunction
    function int nu(int x); return x + 100; endfunction
    function int lower(); return nu(2); endfunction
  endclass
  // declared BELOW the class on purpose
  function int nu(int x); return x + 1; endfunction
endpackage

module tb_d;
  function int mu(int x); return x + 1; endfunction
  class Kmod;
    function int upper(); return mu(1); endfunction
    function int mu(int x); return x + 100; endfunction
    function int lower(); return mu(2); endfunction
  endclass
  hb::Kpkg kp;
  Kmod km;
  initial begin kp = new(); km = new(); end
endmodule
