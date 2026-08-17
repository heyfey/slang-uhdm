// r10uvm84 arm b2 — the THREE implicit class handles.
module g84b2;
  class base2;
    int  bfld;
    int  barr[$];
  endclass
  class mid2 extends base2;
    int  mfld;
  endclass
  class c2b extends mid2;
    int n;
    function void f();
      n = this.barr.size();        // L13 this
      n = super.barr.size();       // L14 super
      n = this.super.barr.size();  // L15 this.super
      n = super.bfld;              // L16 super, ONE step
    endfunction
  endclass
endmodule
