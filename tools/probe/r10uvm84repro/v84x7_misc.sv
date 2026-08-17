// v84x7 — call-returning chains, randomize, part-selects, virtual dispatch.
module v84x7;
  class in7x;
    int         fld;
    logic [7:0] pk;
    int         arr[$];
    function in7x self(); return this; endfunction
    virtual function int vm(); return 1; endfunction
  endclass
  class c7x;
    in7x     h;
    rand int r;
    int      n;
    constraint cc { this.r < this.h.fld; }
    function void f(int i);
      n = this.h.pk[3:0];            // L16 range select on step 2
      n = this.h.pk[i +: 2];         // L17 indexed part select on step 2
      n = this.h.pk[1];              // L18 bit select on step 2
      n = this.h.vm();               // L19 VIRTUAL method on step 2
      n = this.h.self().fld;         // L20 call in the middle of the chain
      void'(this.h.randomize());     // L21 randomize on step 2
      void'(this.randomize() with { r < this.h.fld; });  // L22
      n = this.h.arr.sum();          // L23 array reduction, no with
      n = this.h.arr.sum() with (item); // L24 array reduction WITH
      void'(this.h.arr.find_first_index() with (item == 3)); // L25
    endfunction
  endclass
endmodule
