// r10uvm85 arm a3 — the SUPER roots.  Surelog's rootName is "super" for BOTH
// `super.` and `this.super.`, but the PREFIX constant it compiles from the
// handle is "super" (size 5) vs "this.super" (size 10).
module g85a3;
  class base3;
    int      bq[$];
    int      baa[string];
    int      bn;
    function void bm3(int a); endfunction
  endclass
  class c3 extends base3;
    int      q[$];
    function void f(int k);
      super.bq.delete(0);        // L13 super root, deep, 1 arg
      super.bq.push_back(k);     // L14
      super.baa.delete("k");     // L15
      this.super.bq.delete(0);   // L16 this.super root, deep
      this.super.bq.push_back(k);// L17
      super.bm3(k);              // L18 BARE super.<user>() control
      this.q.delete(k);          // L19 this control in the same body
    endfunction
  endclass
endmodule
