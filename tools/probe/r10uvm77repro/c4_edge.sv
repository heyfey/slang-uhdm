// r10uvm77 arm c4 — the EDGES of the trailing-step rule: other process
// built-ins, the SYSTEM-CALL built-ins r10svs2 already owns (regression
// control), an INDEXED receiver step (r10uvm74's boundary), a DEEP receiver,
// and the FULLNAME regimes r10svs2's s4 measured.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

class inner77;
  process pid;
endclass

class outer77;
  inner77 in;
endclass

module top77c4;
  process  p;
  process  parr[4];
  outer77  o;
  int      q[$];
  int      dyn[];
  int      r;
  string   s;

  function int f;
    // e1 ANOTHER process built-in, parens-less, expression position.
    s = p.get_randstate;
    // e2 the same WITH parens — positive control.
    s = p.get_randstate();
    // e3 SYSTEM-CALL built-in, parens-less: r10svs2's own regime.  MUST NOT
    //    MOVE — it is already correct at base.
    r = q.size;
    // e4 the same WITH parens — positive control.
    r = r + q.size();
    // e5 INDEXED receiver step + parens-less trailing built-in.
    if (parr[2].status == process::KILLED)
      r = r + 1;
    // e6 DEEP receiver (three names) + parens-less trailing built-in.
    if (o.in.pid.status == process::FINISHED)
      r = r + 2;
    // e7 FULLNAME REGIME: inside an INDEX of the array being queried.
    r = r + dyn[dyn.size-1];
    // e8 FULLNAME REGIME: inside a `new[...]` size argument.
    dyn = new[dyn.size + 4];
    return r;
  endfunction
endmodule
