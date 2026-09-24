// r10uvm84 arm a7 — STATEMENT position (Subroutine_call, not Complex_func_call).
module g84a7;
  class inner7;
    function void m7(); endfunction
  endclass
  class c7;
    string  q[$];
    inner7  h;
    function void f();
      this.q.delete(0);
      this.q.push_back("y");
      this.h.m7();
      void'(this.q.size());
    endfunction
  endclass
endmodule
