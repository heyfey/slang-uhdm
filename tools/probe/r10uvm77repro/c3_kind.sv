// r10uvm77 arm c3 — WHICH callee kinds the parens-less rule reaches, and the
// OVER-FIRE GUARDS.  `randomize` is r10svs2's F3 counterexample and is the one
// cell that must NOT move: golden keeps a method_func_call for
// `this.randomize` even though it is parens-less AND in expression position.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

class holder77;
  rand int val;
  int       prop;
  function int meth();
    return prop;
  endfunction
  function int usem();
    int r;
    r = this.randomize;      // R1 GUARD — parens-less BUT golden keeps the call
    r = r + this.randomize(); // R2 parens-ful randomize, control
    r = r + this.meth;       // R3 USER method, parens-less, via `this`
    r = r + this.prop;       // R4 plain PROPERTY, parens-less by nature
    r = r + this.randomize;  // R5 r10svs2's F3 CELL, spelled EXACTLY as F3 wrote it
    return r;
  endfunction
endclass

module top77c3;
  holder77 o;
  process  p;
  int      r;

  function int f;
    r = o.meth;              // U1 USER class method, parens-less, expression
    r = r + o.meth();        // U2 USER class method, parens-ful, control
    r = r + o.prop;          // U3 plain PROPERTY through a handle
    r = r + o.randomize;     // U4 GUARD — randomize through a handle
    return r;
  endfunction

  task t;
    // S1 STATEMENT position, parens-less built-in: must stay a call.
    p.status;
    // S2 STATEMENT position, parens-ful.
    p.status();
  endtask
endmodule
