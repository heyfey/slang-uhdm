// t27 — the `super.<method>(...)` call shape, statement and expression
// position, void function / non-void function / task, with and without
// arguments.  UVM writes `super.do_print(printer);` ~200 times and golden
// makes each one a method_func_call at the METHOD token.
package p27;

  class B;
    int acc;
    function void vf(int a);
      acc = a;
    endfunction
    function int nf(int a);
      return a + 1;
    endfunction
    function bit bf(int a);
      return a > 0;
    endfunction
    task tk(int a);
      acc = a;
    endtask
    function void nop();
      acc = 0;
    endfunction
  endclass

  class D extends B;
    int r;
    // statement position, void
    function void vf(int a);
      super.vf(a);
    endfunction
    // expression position (rhs of an assignment)
    function int nf(int a);
      r = super.nf(a);
      return r;
    endfunction
    // inside an if condition
    function bit bf(int a);
      if (super.bf(a)) begin
        r = 1;
      end
      return r[0];
    endfunction
    // task, statement position
    task tk(int a);
      super.tk(a);
    endtask
    // no-argument call, statement position
    function void nop();
      super.nop();
    endfunction
  endclass

endpackage : p27

module top27;
  import p27::*;
  D d;
  int q;
  initial begin
    d = new();
    d.vf(3);
    q = d.nf(4);
  end
endmodule
