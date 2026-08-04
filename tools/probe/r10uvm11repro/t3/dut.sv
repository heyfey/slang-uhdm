// r10uvm11 t3 — the remaining STRUCTURAL drops the UVM four still report
// through `unsupported constructs encountered`.  Each of these makes emitStmt
// / emitExpr return nullptr, so the construct (and, for a statement, whatever
// it wrapped) never reaches the model at all:
//     statement kind: Wait          `wait (expr);`            (22 UVM sites)
//     statement kind: WaitFork      `wait fork;`              (2 UVM sites)
//     expression kind: NewArray     `a = new[n];` / `new[n](a)` (22 UVM sites)
//     expression kind: TimeLiteral  `9200s`, `#1ns`
//     expression kind: UnboundedLiteral  `$`
package p3;

  class C3;
    int m;
    int q[$];
    int dyn[];
    event ev;

    task w_plain();
      wait (m == 1);
    endtask

    task w_block();
      wait (m == 2) begin
        m = 3;
      end
    endtask

    task w_fork();
      fork
        m = 4;
      join_none
      wait fork;
    endtask

    function void n_array();
      dyn = new[8];
    endfunction

    function void n_array_copy();
      dyn = new[dyn.size() + 1](dyn);
    endfunction

    // Is the whole `new[...]` subtree name-only, or just the copy source?
    function void n_array_ref();
      dyn = new[m](dyn);
    endfunction

    task t_lit();
      #1ns;
      #10;
    endtask

    function void u_lit();
      m = $bits(m);
    endfunction
  endclass

endpackage

module top3;
  p3::C3 c;
  initial begin
    c = new();
    c.n_array();
  end
endmodule
