// r10uvm11 t2 — STATEMENT-position class-method calls through a DEEP
// receiver.  The class-method arm of emitExpr names the call after the
// method and prefixes it with the base of the receiver chain; the built-in
// method arm already implements Surelog's "a statement call reads only the
// FIRST TWO names" rule.  Which one does golden use for a user class method?
package p2;

  class Leaf;
    int v;
    function void doit(); v = 1; endfunction
    function int get(); return v; endfunction
  endclass

  class Mid;
    Leaf l;
    Leaf la[4];
    function void mdo(); endfunction
  endclass

  class Caller;
    Mid m;
    Leaf q[$];
    Leaf arr[4];

    function void s_calls();
      m.mdo();          // 2 names, no index
      m.l.doit();       // 3 names
      q[0].doit();      // 1 name + index
      arr[1].doit();    // 1 name + index
      m.la[2].doit();   // 2 names + index on the second
      m.l.get();        // 3 names, non-void method as a statement
    endfunction

    function int e_calls();
      int t;
      t = m.l.get();       // expression position, 3 names
      t = t + q[0].get();  // expression position, index
      t = t + m.la[2].get();
      return t;
    endfunction
  endclass

endpackage

module top2;
  p2::Caller c;
  initial begin
    c = new();
    c.s_calls();
  end
endmodule
