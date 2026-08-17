// r10uvm84 arm e1 — POSITIONS the a1/c1 arms do not cover: an OUTPUT/INOUT
// argument actual, a `wait` condition, a for-loop condition and step, a
// concatenation LVALUE, and a nested index inside an lvalue.
module g84e1;
  class in1e;
    int fld;
    int arr[$];
  endclass
  class c1e;
    in1e h;
    int  q[$];
    int  n;
    function void g(output int o); o = 1; endfunction
    function void h2(inout int io); io = io + 1; endfunction
    task t();
      wait (this.h.fld > 0);
    endtask
    function void f();
      this.g(this.h.fld);                 // OUTPUT argument actual
      this.h2(this.h.fld);                // INOUT argument actual
      for (int i = 0; i < this.h.fld; i++) n = i;   // for CONDITION
      this.h.fld--;                       // DEC lvalue
      --this.h.fld;                       // PRE-DEC lvalue
      n = this.q[this.h.fld];             // deep chain as an INDEX (rvalue)
      this.q[this.h.fld] = 3;             // deep chain as an INDEX inside an LVALUE
    endfunction
  endclass
endmodule
