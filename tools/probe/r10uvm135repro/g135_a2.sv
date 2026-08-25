// r10uvm135 — GRID ARM a2: THE HOME GRID, and the arm that DECIDES the law.
// MEASUREMENT ONLY.  ONE index kind (a plain CLASS name) written in TWELVE
// homes.  Every home names its own class so a cell can never be read off
// another's answer.
package pkgHomeDelta135;
  class idxPhiCls135;
    int iv;
  endclass

  // A CLASS PROPERTY — an in-body member, so the CLASS component owns the name.
  class propHomeChiCls135;
    bit propPsiMap135 [idxPhiCls135];
    // An IN-BODY method: its local AND its formal.
    function void inBodyOmegaFn135(bit fArgAaMap135 [idxPhiCls135]);
      bit inBodyBbMap135 [idxPhiCls135];
      inBodyBbMap135.delete();
    endfunction
    // An OUT-OF-BODY method, declared here and defined below.
    extern function void oobCcFn135(bit fArgDdMap135 [idxPhiCls135]);
    extern task oobEeTask135();
  endclass

  function void propHomeChiCls135::oobCcFn135(bit fArgDdMap135 [idxPhiCls135]);
    bit oobFfLocalMap135 [idxPhiCls135];
    begin : blkGgScope135
      bit blkHhLocalMap135 [idxPhiCls135];
      blkHhLocalMap135.delete();
    end
    oobFfLocalMap135.delete();
  endfunction

  task propHomeChiCls135::oobEeTask135();
    bit oobIiTaskMap135 [idxPhiCls135];
    oobIiTaskMap135.delete();
  endtask

  // A FREE PACKAGE FUNCTION: its formal and its local.
  function automatic int freeJjFn135(bit fArgKkMap135 [idxPhiCls135]);
    bit freeLlLocalMap135 [idxPhiCls135];
    freeLlLocalMap135.delete();
    return 0;
  endfunction

  // A FREE PACKAGE TASK.
  task automatic freeMmTask135();
    bit freeNnTaskMap135 [idxPhiCls135];
    freeNnTaskMap135.delete();
  endtask

  // A PACKAGE VARIABLE.
  bit pkgOoVarMap135 [idxPhiCls135];
endpackage

// A `$unit`-scope function.
function automatic int unitPpFn135();
  bit unitQqLocalMap135 [pkgHomeDelta135::idxPhiCls135];
  unitQqLocalMap135.delete();
  return 0;
endfunction

module topHomeEps135;
  import pkgHomeDelta135::*;
  // A MODULE VARIABLE and a MODULE's OWN function.
  bit modRrVarMap135 [idxPhiCls135];
  function automatic int modSsFn135();
    bit modTtLocalMap135 [idxPhiCls135];
    modTtLocalMap135.delete();
    return 0;
  endfunction
  propHomeChiCls135 hUuHome135;
  int rUuHome135;
  initial begin
    hUuHome135 = new();
    hUuHome135.oobEeTask135();
    rUuHome135 = modSsFn135();
    rUuHome135 = unitPpFn135();
  end
endmodule
