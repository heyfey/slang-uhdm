// r10uvm84 arm b1 — STEP COUNT and INDEX POSITION, expression position only.
module g84b1;
  class in1;
    int  fld;
    int  arr[$];
    string s;
    function int m1(); return 1; endfunction
  endclass
  class c1b;
    in1    h;
    in1    ha[$];
    string q[$];
    int    n;
    function int one(); return 1; endfunction
    function void f(int i);
      n = this.one();          // L16 1 step, CALL
      n = this.n;              // L17 1 step, member
      n = this.q.size();       // L18 2 steps, builtin call
      n = this.h.fld;          // L19 2 steps, member
      n = this.h.m1();         // L20 2 steps, user call
      n = this.h.arr.size();   // L21 3 steps
      n = this.h.arr[i];       // L22 2 steps then INDEX
      n = this.q[i].len();     // L23 INDEX on step 1
      n = this.ha[i].fld;      // L24 INDEX on step 1, then member
      n = this.h.s.len();      // L25 3 steps, builtin on string
    endfunction
  endclass
endmodule
