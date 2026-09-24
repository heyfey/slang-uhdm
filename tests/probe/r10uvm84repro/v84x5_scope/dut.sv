// v84x5 — STATIC / SCOPED roots and a deeper inheritance chain.
module v84x5;
  class in5x;
    int fld;
    int arr[$];
    static int sfld;
  endclass
  class b5x;
    in5x bh;
    int  bfld;
  endclass
  class m5x extends b5x;
    int mfld;
  endclass
  class c5x extends m5x;
    in5x h;
    int  n;
    static in5x sh;
    function void f();
      n = this.bh.fld;             // L20 inherited member, 2 steps
      n = super.bh.fld;            // L21 super-rooted, 2 steps
      n = this.super.bh.fld;       // L22 this.super-rooted, 2 steps
      n = super.bh.arr.size();     // L23 super-rooted, 3 steps + builtin
      n = this.h.sfld;             // L24 second step is a STATIC member
      n = in5x::sfld;              // L25 :: rooted (control)
      n = c5x::sh.fld;             // L26 :: rooted then member (control)
      n = this.sh.fld;            // L27 this-rooted STATIC handle then member
    endfunction
  endclass
endmodule
