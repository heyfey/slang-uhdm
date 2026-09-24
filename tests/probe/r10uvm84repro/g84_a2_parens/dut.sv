// r10uvm84 arm a2 — parens vs NO parens, and the one-step control.
module g84a2;
  class c2;
    string q[$];
    int    n;
    function void f();
      n = this.q.size();     // 2 steps, parens
      n = this.q.size;       // 2 steps, NO parens
      n = this.n;            // 1 step  (control)
      n = this.n + 1;        // 1 step in an operation (control)
    endfunction
  endclass
endmodule
