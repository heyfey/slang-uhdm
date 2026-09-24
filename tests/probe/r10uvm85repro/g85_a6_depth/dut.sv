// r10uvm85 arm a6 — DEPTH.  Surelog reads the argument list from
// Sibling(Sibling(Constant_bit_select)), so with TWO OR MORE names between the
// handle and the method that sibling is the NEXT Constant_bit_select and the
// arguments are dropped as well.  Measured here for both call families.
module g85a6;
  class leaf6;
    int      arr[$];
    int      m;
    function void lm6(int a); endfunction
  endclass
  class mid6;
    leaf6    l;
    int      arr[$];
    function void mm6(int a); endfunction
  endclass
  class c6;
    mid6     h;
    int      q[$];
    function void f(int k);
      this.q.delete(k);          // L20 depth 1 (member) BUILTIN  -> args KEPT
      this.h.arr.delete(k);      // L21 depth 2 BUILTIN           -> args?
      this.h.l.arr.delete(k);    // L22 depth 3 BUILTIN           -> args?
      this.h.mm6(k);             // L23 depth 1 USER              -> args KEPT
      this.h.l.lm6(k);           // L24 depth 2 USER              -> args?
    endfunction
  endclass
endmodule
