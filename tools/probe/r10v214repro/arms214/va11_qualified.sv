// v214 arm 11 — THE FULLY-QUALIFIED SPELLING.  Surelog's lateBinding answers a
// `::`-qualified name at STEP (1), before the parent-chain walk and before
// `m->Param_assigns()`, and a reference compileExpression already resolved is
// skipped outright (`if (ref->Actual_group()) continue;`).  So a def clone body
// that spells its own package's parameter `pv11::qa11` is the shape most likely
// to be pristine-RIGHT and patched-WRONG.
package pv11;
  parameter int qa11 = 31;
  parameter qb11 = qa11;
  parameter qc11 = qa11 + 2;
  function automatic int qsink11(int a, int b); return a + b; endfunction
  class Q11;
    extern function int q_bare11();
    extern function int q_qual11();
  endclass
  function int Q11::q_bare11();
    return qsink11(qa11, qb11);
  endfunction
  function int Q11::q_qual11();
    return qsink11(pv11::qa11, pv11::qb11) + pv11::qc11;
  endfunction
endpackage
module topv11;
  pv11::Q11 q = new();
  int x, y;
  initial begin x = q.q_bare11(); y = q.q_qual11(); end
endmodule
