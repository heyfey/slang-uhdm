// v85x5 — THE TEXT GATE.  Members whose names merely START with the handle
// spellings, every whitespace spelling of the handle, a comment in the way, the
// parens-less built-in at both depths, and an index whose expression contains a
// CALL (which the bracket skipper must step over without seeing its dot).
module v85x5;
  class in5v;
    int arr[$];
    function int get_q(); return 0; endfunction
  endclass
  class base5v;
    int superq[$];
    int super_q[$];
    int bq[$];
  endclass
  class c5v extends base5v;
    int      thisx[$];
    int      this_q[$];
    in5v     h;
    in5v     hv[4];
    int      qq[4][$];
    int      q[$];
    int      n;
    function void f(int k);
      this.superq.delete(k);        // L23 member whose name STARTS with super
      this.super_q.delete(k);       // L24
      this.thisx.delete(k);         // L25 member starting with this
      this.this_q.delete(k);        // L26
      super.superq.delete(k);       // L27 super root, super-ish member
      this.bq.delete(k);            // L28 INHERITED member through `this`
      this . q.delete(0);           // L29 SPACED handle
      this .q.delete(1);            // L30 space before the dot only
      this. q.delete(2);            // L31 space after the dot only
      this	.	q.delete(3);          // L32 TAB-separated handle
      this./*c*/q.delete(4);        // L33 COMMENT in the way
      this.
        q.delete(5);                // L35 NEWLINE-split handle
      this.qq[this.h.get_q()].delete(k);  // L36 index CONTAINS a call
      this.hv[this.n].arr.delete(k);      // L37 indexed then deeper
      this.q.delete;                // L38 PARENS-LESS built-in
      this.h.arr.delete;            // L39 PARENS-LESS at depth 2
      this.n = 0;
    endfunction
  endclass
endmodule
