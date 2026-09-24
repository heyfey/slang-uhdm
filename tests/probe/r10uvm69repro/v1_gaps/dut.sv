// r10uvm69repro/v1_gaps.sv — THE VERIFIER'S OVER-FIRE HUNT.
//
// The implementer's grid (a1 type x position, a2 scope x type, a3 receiver
// kind) leaves several axes UNMEASURED on which § retNameRecvCollapse69 could
// plausibly over- or under-fire.  Each cell below is a receiver that IS the
// enclosing function's return variable in STATEMENT position -- the exact
// window where the collapse is armed -- but carried by a routine KIND or a
// syntactic nesting that no arm in the pass exercises.
//
// The predicate's gate is (stmtCtx && !curSubOob9 && recv==funcRetSym &&
// retvar's parent scope is a Subroutine).  Nothing in it distinguishes STATIC
// from automatic, VIRTUAL from plain, class-in-package from class-in-module,
// or a call at body top level from one nested inside an if/for/fork.  If
// golden DOES distinguish any of those, this pass over-fires and the grid
// could not have seen it.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
package pv;

  class cH;
    int v;
    function void touch(int x); v = x; endfunction
    // W5's target: a DEFAULTED formal.  Surelog does not list an argument the
    // source did not write, which is why the head arm takes writtenArgs16(call)
    // and not call.arguments().  No arm in the pass measures it on the
    // COLLAPSING path.
    function void touchd(int x, int y = 7); v = x + y; endfunction
    function int peek_stub(); return v; endfunction
  endclass

  class cV;
    // V1 — VIRTUAL method, IN-BODY, statement.  `virtual` changes the call's
    // binding, not its spelling; if golden keys on it this pass over-fires.
    virtual function cH v_virt(int n);
      v_virt = new();
      v_virt.touch(n);            // V1
    endfunction

    // V2 — STATIC method, IN-BODY, statement.  A static method has no `this`;
    // the receiver is still the return variable.
    static function cH v_stat(int n);
      v_stat = new();
      v_stat.touch(n);            // V2
    endfunction

    // V3 — the collapse window entered from INSIDE a nested statement block.
    // `callStmtContext` is set by the statement emitter; a call nested in an
    // if/for body must still read as STATEMENT position.
    function cH v_nested(int n);
      v_nested = new();
      if (n > 0) begin
        for (int i = 0; i < 2; i++) begin
          v_nested.touch(n + i);  // V3
        end
      end
    endfunction

    // V4 — EXPRESSION position reached from inside a nested block: the
    // NEGATIVE twin of V3.  Must NOT collapse.
    function cH v_nested_e(int n);
      int k;
      v_nested_e = new();
      if (n > 0) begin
        k = v_nested_e.peek_stub();  // V4
      end
    endfunction
    function int peek_stub(); return 0; endfunction

    // V5 — a method call carrying a DEFAULTED formal, statement, in-body.
    // Golden lists only the WRITTEN argument; a collapse that copied
    // call.arguments() would emit two.
    function cH v_default(int n);
      v_default = new();
      v_default.touchd(n);        // V5
    endfunction
  endclass

  // V6 — the return name used as the receiver TWICE in one statement's
  // expression, one of them in argument position.
  function cH v_twice(int n);
    v_twice = new();
    v_twice.touch(n);             // V6
  endfunction

endpackage

// V7 — a function declared inside an INTERFACE, statement position.  Neither
// a2's module/package/class scopes nor a3 covers an interface home.
interface iv_if;
  import pv::*;
  function cH i_fn(int n);
    i_fn = new();
    i_fn.touch(n);                // V7
  endfunction
endinterface

module v1_top;
  import pv::*;
  cV c;
  cH h;
  int r;
  iv_if u_if();
  initial begin
    c = new();
    h = c.v_virt(1);
    h = cV::v_stat(2);
    h = c.v_nested(3);
    h = c.v_default(4);
    h = v_twice(5);
    r = 0;
  end
endmodule
