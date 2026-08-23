// r10v113 / v113_ctx.sv — ADVERSARIAL CONTEXT GRID for
// § classOwnLateMethodBindsPkgFn113.  Purpose-built golden (Surelog is the
// reference).  Every cell is an UNQUALIFIED call to a name that is BOTH a
// package free subroutine and a method of the caller's OWN class declared
// BELOW the caller — reached from a different syntactic context each time.
// Names, orders, cases and numbers are deliberately varied so an arm cannot
// agree with golden by accident.
package qctx;

  int  Kseed = 7;

  function automatic int Wren(int n); return n * 3 + 1; endfunction
  function automatic int spool(int n); return n * 5 + 2; endfunction
  task    automatic Drain(int n); endtask
  function automatic int recur(int n); return n < 2 ? 1 : n * recur(n-1); endfunction
  function automatic int defarg(int n = 4, int m = 9); return n + m; endfunction

  class Mesh;
    rand int v;
    int prop_init = Wren(11);              // property initializer (no currentSub)
    static int sprop = spool(12);          // static property initializer

    function new();                        // CONSTRUCTOR, above Mesh::Wren
      v = Wren(1);
    endfunction

    function int inbody();                 // IN-BODY, above
      return Wren(2);
    endfunction

    static function int statm();           // STATIC method, above
      return spool(3);
    endfunction

    extern function int oobm();             // OUT-OF-BODY, prototype above

    task inTask();                          // in-body TASK caller
      int t; t = Wren(4);
    endtask

    function int inForeach();               // foreach header body
      int q[4]; int a = 0;
      foreach (q[i]) a += Wren(i);
      return a;
    endfunction

    function int inCast();                  // cast context
      return int'(Wren(5));
    endfunction

    function int inConcat();                // concat context
      logic [63:0] z = {32'(Wren(6)), 32'(spool(6))};
      return z[3:0];
    endfunction

    function int inWith();                  // with-clause
      int q[$] = '{1,2,3};
      return q.sum() with (int'(item) + Wren(7));
    endfunction

    function int qualThis();                // this.-qualified: must NOT fall out
      return this.Wren(8);
    endfunction

    function int recurCall();               // recursive free function
      return recur(5);
    endfunction

    function int defArgCall();              // default arguments, fewer actuals
      return defarg(1);
    endfunction

    task taskBeside();                      // free TASK of a name with a method below
      Drain(9);
    endtask

    // ---- THE COLLIDING METHODS, all declared BELOW every caller above ----
    function int Wren(int n); return n + 100; endfunction
    static function int spool(int n); return n + 200; endfunction
    task Drain(int n); endtask
    function int recur(int n); return n + 300; endfunction
    function int defarg(int n = 4, int m = 9); return n + 400; endfunction

    // ---- and callers written BELOW the collision: must bind the METHOD ----
    function int afterInbody(); return Wren(21); endfunction
    function int afterStat();   return spool(22); endfunction

    constraint c_v { v == Wren(2); }
  endclass

  function int Mesh::oobm(); return spool(31); endfunction

endpackage

module tb_ctx;
  import qctx::*;
  Mesh m;
  initial begin m = new(); end
endmodule
