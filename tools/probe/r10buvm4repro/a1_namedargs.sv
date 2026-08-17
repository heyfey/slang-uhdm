// r10buvm4 arm a1 — NAMED ARGUMENTS: what does golden put in vpiArgument, in
// what ORDER, and what happens to a SKIPPED defaulted formal?
//
// The corpus shape (uvm_pkg.sv:12509) is a CONSTRUCTOR called with FIVE named
// arguments against a SIX-formal `new`, the SKIPPED formal being the FIRST one
// and defaulted.  Every cell below varies ONE axis of that shape so the law can
// be read off the dump rather than guessed.
package p1;

  class ctor6;
    string  a;
    string  b;
    int     c;
    int     d;
    bit     e;
    // SIX formals, formals 1/2/3/5/6 defaulted, formal 4 (`d`) MANDATORY —
    // exactly the corpus shape (uvm_factory_override::new).
    function new(string a = "", string b = "", int c = 0, int d,
                 int e = 7, bit f = 0);
      this.a = a; this.b = b; this.c = c; this.d = d; this.e = f;
    endfunction
  endclass

  // Plain package-scope function with the same formal shape.
  function int pf6(string a = "", string b = "", int c = 0, int d,
                   int e = 7, bit f = 0);
    return c + d + e;
  endfunction

  class holder;
    int acc;
    // Class METHOD (not a ctor) with the same formal shape.
    function int mf6(string a = "", string b = "", int c = 0, int d,
                     int e = 7, bit f = 0);
      return c + d + e;
    endfunction
    // TASK with the same formal shape.
    task mt6(string a = "", string b = "", int c = 0, int d,
             int e = 7, bit f = 0);
      acc = c + d + e;
    endtask
  endclass

  class runner;
    ctor6  h1, h2, h3, h4, h5;
    holder hh;
    int    r1, r2, r3, r4, r5, r6;
    int    q;
    task go;
      hh = new();
      // C1 — THE CORPUS SHAPE: ctor, all-named, FIRST defaulted formal SKIPPED,
      //      remaining five in FORMAL order.
      h1 = new(.b("bb"), .c(1), .d(2), .e(3), .f(1));
      // C2 — ctor, all-named, REORDERED (written order != formal order) and the
      //      first formal skipped.
      h2 = new(.d(2), .b("bb"), .f(1), .c(1), .e(3));
      // C3 — ctor, ONLY the mandatory formal named (four defaulted skipped).
      h3 = new(.d(9));
      // C4 — ctor, MIXED positional then named, with a skip.
      h4 = new("aa", .d(4), .f(1));
      // C5 — ctor, named arg with an EMPTY actual `.c()` (SV: use the default).
      h5 = new(.b("bb"), .c(), .d(5));
      // C6 — PACKAGE function, all-named, first skipped, reordered.
      r1 = pf6(.d(2), .b("bb"), .c(1));
      // C7 — package function, only the mandatory formal named.
      r2 = pf6(.d(9));
      // C8 — CLASS METHOD through a handle, all-named with a skip.
      r3 = hh.mf6(.b("bb"), .d(2), .f(1));
      // C9 — class method, reordered.
      r4 = hh.mf6(.d(2), .c(1), .b("bb"));
      // C10 — TASK call, all-named with a skip.
      hh.mt6(.b("bb"), .d(2), .f(1));
      // C11 — task call, reordered.
      hh.mt6(.d(2), .b("bb"), .c(1));
      // C12 — PURELY POSITIONAL control: the trailing defaults are skipped by
      //       position.  This is the shape § writtenCallArgs16 already handles;
      //       it must NOT move.
      r5 = pf6("aa", "bb", 1, 2);
      // C13 — positional control on a class method.
      r6 = hh.mf6("aa", "bb", 1, 2);
      // C14 — named argument whose ACTUAL is a call (the corpus writes
      //       `.orig_type_name(original_type.get_type_name())`).
      q = pf6(.d(hh.mf6(.d(1))), .c(2));
    endtask
  endclass
endpackage

module a1_namedargs;
  p1::runner r;
  initial begin
    r = new();
    r.go();
  end
endmodule
