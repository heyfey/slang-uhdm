// v85xB — OVER-FIRE HUNT.  This arm's SITE 1 assumes `arguments()[0]` of a
// non-`$` system subroutine is the RECEIVER.  `std::randomize(this.n)` is the
// counter-example: a GLOBAL call whose FIRST ARGUMENT is a this-rooted chain, so
// the text gate sees "this.n" and can mint a handle call out of a call that has
// no receiver at all.  Also the whitespace spelling of the one-step form, whose
// method span is computed as `receiver-text length + 1`.
module v85xb;
  class cbv;
    rand int n;
    rand int m;
    int      q[$];
    function void um(int a); endfunction
    function void f(int k);
      void'(std::randomize(this.n));            // L14 GLOBAL call, this-rooted arg1
      void'(std::randomize(this.n, this.m));    // L15 two this-rooted args
      // (`std::randomize(...) with {...}` is a Surelog SYNTAX ERROR — not spellable)
      void'(this.randomize());                  // L17 one-step control
      void'(this . randomize());                // L18 SPACED one-step
      this . um(k);                             // L19 SPACED one-step USER
      this.q.delete(k);                         // L20 control
      this.n = 0;
    endfunction
  endclass
endmodule
