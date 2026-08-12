// r10svs3 ARM a5 — THE GAP THE OTHER FOUR ARMS LEAVE OPEN, found by reading the
// call sites rather than the brief.
//
// § thisSuperNewAssignNoStmt3 is gated OFF inside a constructor in exactly two
// ways, and NEITHER of them covers a NESTED block:
//   * CALL SITE 5 (TaskFuncEmit) tests `!tfBodyCtor27` explicitly.
//   * CALL SITES 3 and 4 (StmtEmit) are unreachable for a constructor because
//     emitStmt diverts at `if (tfBodyCtor27 && tfBodyStmt9 == &stmt) return
//     emitCtorBody27(...)` — but that test names the TOP-LEVEL body statement
//     ONLY (`tfBodyStmt9 == &stmt`), and emitCtorBody27's EK_FSN case recurses
//     straight back into `emitStmt` for every element it keeps.
//   * CALL SITES 1 and 2 (the WRITTEN `begin`/`fork` arm) have NO constructor
//     gate at all.
// So a drop written inside an EXPLICIT block inside a constructor reaches call
// site 1 and fires, while a4's `new` cell proved golden KEEPS the drop in a
// constructor's own statement list.  Whether golden also keeps it one block
// level down is UNMEASURED by a1-a4, and if it does, this law OVER-FIRES on
// every uvm-1.2 constructor that wraps its body in a begin/end.
//
// Cells (r1-r4 are the gap; r5-r7 are the controls that make the reading legible):
//   r1  constructor, drop inside an EXPLICIT begin/end nested in the body
//   r2  constructor, drop inside a begin nested inside an `if`
//   r3  constructor, drop inside a `fork`/`join` — call site 1's other kind
//   r4  constructor, drop as the SOLE content of a nested begin (empty-begin cell)
//   r5  CONTROL: plain function, drop inside a nested begin (a4 q8 without the
//       leading statement) — this one MUST fire, and pins the instrument
//   r6  CONTROL: constructor, drop in its OWN list (a4 `new` repeat, no base)
//   r7  CONTROL: constructor, nested begin with NO drop in it at all
class ctornest;
  logic [7:0] d[];
  logic [7:0] e[];
  int         s;
  ctornest    h;

  function new(int k);
    s = k;
    begin
      this.d = new[3];
      s = 2;
    end
  endfunction

  function void r2();
    if (s) begin
      this.d = new[3];
      s = 3;
    end
  endfunction

  task r3();
    fork
      this.d = new[3];
      s = 4;
    join
  endtask

  function void r4();
    s = 5;
    begin
      this.d = new[3];
    end
  endfunction

  function void r5();
    begin
      this.d = new[3];
      s = 6;
    end
  endfunction

  function void r7();
    s = 8;
    begin
      this.e = e;
      s = 9;
    end
  endfunction
endclass

// r6 needs a SECOND class, because a class has only one constructor and this
// file's `ctornest::new` is already spent on r1.
class ctorplain;
  logic [7:0] d[];
  int         s;

  function new();
    s = 1;
    this.d = new[3];
    s = 2;
  endfunction
endclass

// r2/r3/r4 live in `ctornest` but its constructor takes an argument, so the
// nested-block constructor cell and the plain cells are exercised from one
// initial block.
module top5;
  ctornest  cn;
  ctorplain cp;
  initial begin
    cn = new(1);
    cp = new();
    cn.r2();
    cn.r3();
    cn.r4();
    cn.r5();
    cn.r7();
  end
endmodule
