// r10v215 ADVERSARIAL ARM v10 — EVERY MODPORT DROPPED, and the interface still
// carrying ports/clocking/tasks.  The law's extreme cell: `Modports()` goes
// from a full vector to a NULL POINTER on an interface that is instantiated,
// port-connected PLAINLY (no modport qualifier) and read hierarchically.  A
// null vector that some later consumer dereferences would segfault here
// (verify_golden.py reads a 139 as SLANG_REJECT, RESUME §9 — the rcs above are
// what convicts it).
interface v10_if;
  logic clk;
  logic frame;
  logic [3:0] data;
  clocking cb @(posedge clk);
    inout frame;
    inout data;
  endclocking
  task automatic tk(input logic v);
  endtask
  modport mpc (clocking cb);
  modport mpi (import tk);
  modport mpe (clocking cb, import tk);
endinterface

module v10_sub (v10_if p);
  assign p.frame = p.clk;
endmodule

module top;
  v10_if i1();
  v10_if i2();
  v10_sub s1(i1);
  v10_sub s2(i2);
  logic z;
  always_comb z = i1.data[0];
endmodule
