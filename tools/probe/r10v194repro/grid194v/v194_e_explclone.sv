// r10v194 arm E — CLOSING THE EXPLICIT-IMPORT GAP arm A opened.
//
// The r10uvm194 fence is `pkgImportCloneTfs16`, populated ONLY under
// `pkgImportCloneEmit` (TaskFuncEmit.cpp:6682 — the WILDCARD clone).  The
// sibling fence one function away in `endSelTrack` (§ localBlockStmtSelBinds122,
// StmtEmit.cpp:417) is the BROADER `pkgImportCloneEmit || importCloneEmit ||
// importCopyTsInst`.  Arm A showed an explicit `import p::C;` produces no
// package-level clone listing of an OUT-OF-BODY method, so the narrow fence is
// not reachable there.  This arm asks the same question of the shapes arm A
// left out:
//
//   * an explicitly imported class whose method is written IN BODY with a
//     direct select (the `cd != nullptr` half of § 37's predicate, which the
//     exemption also reaches);
//   * an explicitly imported class RE-EXPORTED by a third package;
//   * a package that explicitly imports the class AND wildcard-imports the
//     same home (both clone paths live at once).
package ve194_src;
  class VE194;
    // IN BODY, direct select.
    function string e_in();
      int i; i=0;
      e_in = {e_in," "};
      e_in[i] = 8'h41;
    endfunction
    extern function string e_out();
  endclass
  function string VE194::e_out();
    int i; i=0;
    e_out = {e_out," "};
    e_out[i] = 8'h42;
  endfunction
endpackage

// EXPLICIT import + EXPORT.
package ve194_mid;
  import ve194_src::VE194;
  export ve194_src::VE194;
  function int e_mid();
    VE194 h = new();
    string a = h.e_in();
    string b = h.e_out();
    return a.len() + b.len();
  endfunction
endpackage

// BOTH clone paths at once: explicit AND wildcard on the same home.
package ve194_both;
  import ve194_src::VE194;
  import ve194_src::*;
  function int e_both();
    VE194 h = new();
    string a = h.e_in();
    string b = h.e_out();
    return a.len() + b.len();
  endfunction
endpackage

module ve194_top;
  import ve194_mid::*;
  import ve194_both::*;
  int r1, r2;
  initial begin
    r1 = e_mid();
    r2 = e_both();
  end
endmodule
