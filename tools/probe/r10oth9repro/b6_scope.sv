// r10oth9 arm b6 — THE SCOPE NEGATIVE CONTROL.
//
// § arrayVarSignedWritten8 is SCOPE-BOUND: at SUBROUTINE / STATEMENT-BLOCK scope
// golden puts signedness on the ELEMENT VAR and nothing on the array_var, which
// is the OPPOSITE of the class/module rule and is what src/TaskFuncEmit.cpp
// already implements (`reg0->VpiSigned(true)`).  Any law this pass adds to the
// ELEMENT TYPESPEC must not leak there.
//
// These cells exist TO BE READ AND LEFT ALONE: they must be byte-identical
// before and after the patch, and the patch must not touch TaskFuncEmit.cpp or
// StmtEmit.cpp at all.
//
// n01..n03  subroutine locals   n04..n05  statement-block locals
// p01       the class witness in the same file, so the two scopes are compared
//           against each other in ONE database
class pc;
  rand byte              p01_data[];
  byte                   p02_fcs;
endclass

module b6_top;
  pc ph;
  int r;
  function automatic int f();
    byte                 n01_loc_dyn[];
    byte                 n02_loc_q[$];
    int                  n03_loc_int[];
    n01_loc_dyn = new[1];
    n02_loc_q.push_back(0);
    n03_loc_int = new[1];
    return n01_loc_dyn.size() + n02_loc_q.size() + n03_loc_int.size();
  endfunction
  initial begin
    byte                 n04_blk_dyn[];
    byte                 n05_blk_q[$];
    ph = new();
    n04_blk_dyn = new[1];
    n05_blk_q.push_back(0);
    r = f() + n04_blk_dyn.size() + n05_blk_q.size();
  end
endmodule
