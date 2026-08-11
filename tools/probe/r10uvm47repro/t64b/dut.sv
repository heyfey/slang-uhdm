// r10uvm46 arm t64b — the THREE unmeasured halves of t64a's finding.
//
// t64a established that a class method carrying BOTH a visibility qualifier and
// `automatic` loses its name, its formals and its body in golden, and that SIX
// such methods in one class collapse onto ONE object (`function ''`, nio=0,
// stmt unset, at the LAST one's line, but with the FIRST one's KIND).  Three
// things that leaves open, each its own class here so they cannot interfere:
//   c65a — is `protected` the same as `local`, and what VpiVisibility?
//   c65b — with a TASK declared FIRST, is the collapsed object a task?
//   c65c — a class whose ONLY such method is a TASK: function or task?
//   c65d — `protected` and `local` mixed: one collapsed object or two?
package p65;

  class c65a;
    protected function automatic int unsigned pf(int unsigned a);
      return a;
    endfunction
  endclass

  class c65b;
    local task automatic t_first(int a);
      $display("%0d", a);
    endtask
    local function automatic int f_second(int a);
      return a;
    endfunction
  endclass

  class c65c;
    local task automatic t_only(int a);
      $display("%0d", a);
    endtask
  endclass

  class c65d;
    protected function automatic int p_one(int a);
      return a;
    endfunction
    local function automatic int l_two(int a);
      return a;
    endfunction
  endclass

endpackage

module t64b;
  initial begin
    p65::c65a h;
    h = new();
  end
endmodule
