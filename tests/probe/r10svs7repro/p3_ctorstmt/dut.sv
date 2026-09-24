// r10svs7 HAZARD PROBE -- NOT a cell of the law, but the measurement that had to
// come FIRST or the whole grid would have been contaminated.
//
// SURELOG KEEPS ONLY THE **LAST** STATEMENT OF A CLASS CONSTRUCTOR BODY.
// A non-`new` class method keeps them all.  Golden, measured:
//
//   function new()  -- WRITTEN `p = 1;` (l.24) and `q = 2;` (l.25)
//                   -- GOLDEN:  ONE  vpiStmt, `assignment line:25:7`  (the LAST)
//   function go()   -- WRITTEN `p = 3;` (l.28) and `q = 4;` (l.29)
//                   -- GOLDEN:  TWO  vpiStmt, `line:28:7` and `line:29:7`
// (EXECUTED with this exact file: SLANG_UHDM=<any> ./ct7arm.sh p3_ctorstmt.sv)
//
// Pre-existing, orthogonal to § covergroupNewCall7, and NOT touched by this
// pass.  It is recorded because it SILENTLY DELETES ARM CELLS: r10svs7's first
// a1_witness.sv put three cells in one constructor and golden showed only the
// third, which would have read as "golden drops covergroup new".  Every arm in
// this directory therefore uses ONE STATEMENT PER CONSTRUCTOR.
//
// SVSwitch's own Coverage.sv `function new()` has exactly ONE statement, which
// is why the corpus head is unaffected by this.
module p3;
  class cov7;
    int p, q;
    function new();
      p = 1;
      q = 2;
    endfunction
    function void go();
      p = 3;
      q = 4;
    endfunction
  endclass
endmodule
