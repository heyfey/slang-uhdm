// r10uvm85 arm b1 — EDGES.  A DEEP `super.`-rooted USER method (the one
// rootName the § thisRecvCall11 arm declines to guess at), the PARENS-LESS
// built-in written as a statement, and the two spellings this law's TEXT gate
// deliberately DECLINES (a spaced handle, an escaped identifier).
module g85b1;
  class leaf1;
    int      arr[$];
    function void lm1(int a); endfunction
  endclass
  class base1;
    leaf1    bl;
    int      bq[$];
  endclass
  class c1b extends base1;
    leaf1    h;
    int      q[$];
    int      n;
    function void f(int k);
      super.bl.lm1(k);        // L18 DEEP super, USER method
      this.bl.lm1(k);         // L19 the same member through `this`
      this.q.delete;          // L20 PARENS-LESS built-in, statement
      this . q.delete(0);     // L21 SPACED handle — the gate declines
      this.h.arr.delete(k);   // L22 depth-2 built-in control
      this.q.delete(k);       // L23 depth-1 control
      this.super.bl.lm1(k);   // L24 DEEP this.super, USER method
      super.bl.arr.delete(k); // L25 DEEP super, BUILT-IN two names down
      this.super.bq.delete(k);// L26 this.super, BUILT-IN, depth 1
    endfunction
  endclass
endmodule
