// r10buvm4 arm a2 — WHICH CALL KINDS take the WRITTEN list and which take the
// FORMAL-SLOT list?  a1 established the split for `func_call` (formal slots,
// zero placeholders) vs `method_func_call` (written list); this arm walks the
// remaining kinds so the predicate can name a UHDM object kind rather than a
// guess about receivers.
package p2;

  function int gf(string a = "", int b = 0, int c, int d = 0);
    return b + c;
  endfunction

  task gt(string a = "", int b = 0, int c, int d = 0);
  endtask

  class base;
    int v;
    function new(string a = "", int b = 0, int c = 0, int d = 0);
      v = b + c + d;
    endfunction
  endclass

  class derived extends base;
    int w;
    // D1 — super.new with NAMED arguments, one formal skipped.
    function new(int k);
      super.new(.c(k), .b(2));
      w = k;
    endfunction
  endclass

  class caller;
    int r1, r2, r3, r4, r5;
    derived dh;
    function int im(string a = "", int b = 0, int c, int d = 0);
      return b + c;
    endfunction
    static function int sm(string a = "", int b = 0, int c, int d = 0);
      return b + c;
    endfunction
    task run;
      // E1 — an IN-CLASS method call with NO receiver, named args.
      r1 = im(.c(1), .b(2));
      // E2 — the same through `this.`
      r2 = this.im(.c(1), .b(2));
      // E3 — a PACKAGE function called from inside a class, named args.
      r3 = gf(.c(1), .b(2));
      // E4 — a PACKAGE task called from inside a class, named args.
      gt(.c(1), .b(2));
      // E5 — a STATIC class method through `::`, named args.
      r4 = caller::sm(.c(1), .b(2));
      // E6 — the constructor of a DERIVED class (drives D1).
      dh = new(7);
      // E7 — an in-class method call, named args, REORDERED.
      r5 = im(.b(2), .c(1));
    endtask
  endclass
endpackage

module a2_kindgrid;
  int m1, m2;
  p2::caller c;
  p2::base   b1, b2;
  initial begin
    c = new();
    c.run();
    // F1 — MODULE-scope call of a package function, named args.
    m1 = p2::gf(.c(3), .b(4));
    // F2 — MODULE-scope package task, named args.
    p2::gt(.c(3), .b(4));
    // F3 — ctor of a package class from module scope, named args, reordered.
    b1 = new(.c(5), .b(6));
    // F4 — ctor, ONE named arg, all others defaulted.
    b2 = new(.d(9));
    m2 = m1;
  end
endmodule
