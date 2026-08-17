// r10uvm85 arm a9 — the ONE-STEP handle call, which is the OTHER arm
// (paList_of_arguments): named after the METHOD, prefix the same handle
// constant.  Includes the randomize family, whose receiver slang also hides.
module g85a9;
  class c9;
    rand int n;
    int      q[$];
    function void um9(int a); endfunction
    function void f(int k);
      this.um9(k);                 // L10 one-step USER
      void'(this.randomize());     // L11 one-step system method on `this`
      void'(this.randomize(n));    // L12
      this.q.delete(k);            // L13 positive control
    endfunction
  endclass
endmodule
