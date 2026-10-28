// § oobCloneViewKeepsPristine455v
// s imports only q, q's class extends p's B (LAW C fall-back), plus a free task
package p;
  function int f(int a); $display(a); return a; endfunction
  task t(int a); $display(a); endtask
  class B;
    function int f(int a); return a + 1; endfunction
  endclass
endpackage
package q;
  import p::*;
  class C extends B;
    int v;
    extern task g();
  endclass
  task C::g(); v = f(v); t(v); endtask
endpackage
package s;
  import q::*;
  task run(); C c = new; c.g(); endtask
endpackage
module top;
  import s::*;
  initial run();
endmodule
