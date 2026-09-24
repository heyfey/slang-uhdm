// r10uvm84 arm a6 — NO call at all: plain nested member `this.h.fld`.
module g84a6;
  class inner6;
    int fld;
    int arr[$];
    function int m6(); return 1; endfunction
  endclass
  class c6;
    inner6 h;
    int    n;
    function void f();
      n = this.h.fld;          // 2 steps, no call
      n = this.h.arr.size();   // 3 steps, call
      n = this.h.m6();         // 2 steps, USER method call
      if (this.h.fld == 0) n = 1;
    endfunction
  endclass
endmodule
