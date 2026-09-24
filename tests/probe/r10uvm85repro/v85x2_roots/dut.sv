// v85x2 — the SUPER / THIS.SUPER roots across both call families, both depths,
// arities 0..3, plus a base member SHADOWED by a derived member of the same
// name (where the written handle is the only thing that tells them apart).
module v85x2;
  class base2v;
    int      bq[$];
    int      shad[$];
    int      baa[string];
    int      bn;
    function void bm(int a); endfunction
    function void bm3(int a, int b, int c); endfunction
  endclass
  class mid2v extends base2v;
    int      mq[$];
    function void mm(int a); endfunction
  endclass
  class c2v extends mid2v;
    int      shad[$];
    int      q[$];
    function void f(int k);
      super.bq.delete(0);              // L21 super deep builtin 1
      super.bq.delete();               // L22 0
      super.bq.insert(0, k);           // L23 2
      super.baa.delete("x");           // L24 1
      super.shad.delete(k);            // L25 base member, SHADOWED name
      this.shad.delete(k);             // L26 derived member, same name
      this.super.bq.delete(0);         // L27 this.super deep builtin
      this.super.shad.delete(k);       // L28 this.super + shadow
      super.bm(k);                     // L29 one-step super USER
      super.bm3(k, k, k);              // L30 one-step super USER, 3 args
      super.mm(k);                     // L31 one-step, method of the MIDDLE class
      void'(super.bq.size());          // L32 super builtin, value dropped
      void'(this.super.bq.size());     // L33
      this.q.delete(k);                // L34 this control
    endfunction
  endclass
endmodule
