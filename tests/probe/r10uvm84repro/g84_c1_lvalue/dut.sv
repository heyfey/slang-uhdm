// r10uvm84 arm c1 — LVALUE and OTHER positions of the deep this-rooted chain.
module g84c1;
  class in1c;
    int fld;
    int arr[$];
  endclass
  class c1c;
    in1c   h;
    string q[$];
    int    n;
    function void f(int i);
      this.h.fld = 5;             // L12 LVALUE, member
      this.h.arr[i] = 6;          // L13 LVALUE, member then index
      this.h.fld++;               // L14 INC
      this.h.fld += 2;            // L15 op-assign
      if (this.h.fld) n = 1;      // L16 bare condition
      n = this.h.fld ? 1 : 2;     // L17 ternary condition
      $display(this.h.fld);       // L18 sys arg
      n = g(this.h.fld);          // L19 user call arg
      n = {this.h.fld, 1'b0};     // L20 concat
      // (a `this.q[this.h.fld]` cell is DELIBERATELY ABSENT: slang rejects a string-queue index)
      foreach (this.q[j]) n = j;  // L22 foreach header
    endfunction
    function int g(int x); return x; endfunction
  endclass
endmodule
