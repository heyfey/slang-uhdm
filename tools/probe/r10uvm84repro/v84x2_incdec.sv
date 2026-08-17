// v84x2 — INC/DEC and op-assign in every shape, incl. a deep chain in the INDEX
// of an inc/dec target (the `lvIncDecTarget84` leak candidate).
module v84x2;
  class in2x;
    int fld;
    int arr[$];
  endclass
  class c2x;
    in2x h;
    in2x g;
    int  q[$];
    int  n;
    function void f(int i);
      this.h.fld++;                 // L14 post-inc lvalue
      ++this.h.fld;                 // L15 pre-inc lvalue
      this.h.fld--;                 // L16 post-dec
      --this.h.fld;                 // L17 pre-dec
      this.h.arr[i]++;              // L18 inc of an INDEXED deep chain
      this.q[this.g.fld]++;         // L19 inc target indexed BY a deep chain
      this.h.fld += this.g.fld;     // L20 op-assign, deep chain on BOTH sides
      this.h.arr[this.g.fld] = 1;   // L21 lvalue indexed by a deep chain
      n = this.h.fld++;             // L22 inc in an rvalue position
    endfunction
  endclass
endmodule
