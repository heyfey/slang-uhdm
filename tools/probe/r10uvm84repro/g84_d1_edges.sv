// r10uvm84 arm d1 — the EDGES of the predicate: a with-clause in the FIRST step,
// the corpus's assoc-array built-ins, a RANGE select on the SECOND step, and the
// one-step `this.super` control.  Every cell compiles on BOTH tools.
module g84d1;
  class in1d;
    int         fld;
    int         arr[$];
    logic [7:0] pk;
  endclass
  class bd;
    int bfld;
  endclass
  class c1d extends bd;
    in1d     h;
    int      q[$];
    int      am[string];
    int      n;
    function int get_n(); return 1; endfunction
    function void f(string k);
      n = this.q.sum() with (item);    // with-clause on step 1
      n = this.q.size() + 1;           // plain control
      n = this.am.exists(k);           // assoc built-in (the corpus family)
      n = this.am.num();               // assoc built-in, no args
      n = this.super.bfld;             // this.super, ONE step
      n = this.h.pk[1:0];              // RANGE select on step 2
      n = this.h.fld + this.h.fld;     // twice on one line
      n = this.h.arr[1];               // ELEMENT select on step 2
    endfunction
  endclass
endmodule
