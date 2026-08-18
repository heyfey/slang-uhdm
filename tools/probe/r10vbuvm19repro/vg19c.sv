// vbuvm19 adversarial grid C — CONSTRUCTORS, QUALIFIED HEADERS, $unit,
// import clones, instantiated program/interface.
package vcp19;
  class vbase19; int z19; endclass

  class vk19;
    vbase19 ka19[int];
    int     kb19[string];
    extern function new();
    extern function void thishdr19();
    extern function void thisboth19();
  endclass

  // 1 — an OUT-OF-BODY CONSTRUCTOR body holding the shape
  function vk19::new();
    foreach (ka19[i]) $display("ct", ka19[i]);
    ka19[0] = null;
  endfunction

  // 2 — the foreach HEADER written `this.`-qualified, bare select assignment
  function void vk19::thishdr19();
    foreach (this.kb19[i]) $display("th", kb19[i]);
    kb19["a"] = 1;
  endfunction

  // 3 — both header and assignment `this.`-qualified
  function void vk19::thisboth19();
    foreach (this.ka19[i]) $display("tb", ka19[i]);
    this.ka19[1] = null;
  endfunction

  int cgv19[string];
  int chv19[string];

  // 4 — the foreach header written PACKAGE-QUALIFIED, bare select assignment
  function void qualhdr19();
    foreach (vcp19::cgv19[i]) $display("qh", cgv19[i]);
    cgv19["b"] = 2;
  endfunction

  // 5 — an IN-BODY constructor (control)
  class vm19;
    vbase19 ma19[int];
    function new();
      foreach (ma19[i]) $display("ib", ma19[i]);
      ma19[0] = null;
    endfunction
  endclass

  // 6 — plain positive control in this package
  function void ctrl19();
    foreach (chv19[i]) $display("cc", chv19[i]);
    chv19["c"] = 3;
  endfunction
endpackage

// 7 — THE IMPORT-CLONE ARM
package vimp19;
  import vcp19::*;
endpackage

// 8 — an EXPLICIT (non-wildcard) import clone
package vimp2_19;
  import vcp19::ctrl19;
endpackage

// 9 — $unit-level function (compilation-unit scope), NOT in any package
int uvar19[string];
function automatic void unitfn19();
  foreach (uvar19[i]) $display("un", uvar19[i]);
  uvar19["d"] = 4;
endfunction

// 10 — an INSTANTIATED program and interface (elaborated copies exist)
interface vif2_19;
  int iv19[string];
  function void iffn19();
    foreach (iv19[k]) $display("if2", iv19[k]);
    iv19["e"] = 5;
  endfunction
endinterface

program vprg2_19;
  int pv19[string];
  function void prgfn19();
    foreach (pv19[k]) $display("pg2", pv19[k]);
    pv19["f"] = 6;
  endfunction
  initial prgfn19();
endprogram

module vtopc19;
  vif2_19 wi19();
  vprg2_19 wp19();
  initial unitfn19();
endmodule
