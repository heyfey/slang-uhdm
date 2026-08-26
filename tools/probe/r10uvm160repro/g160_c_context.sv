// r10uvm160 grid, arm C — WHERE THE BAD SUB-EXPRESSION SITS.
// ONE bad sub-expression (`t.gt()` on an int-typed type-parameter local) in
// nine syntactic CONTEXTS.  This arm is what decides the law's SCOPE: every
// other compound `badExpr` in slang hands the PARTIALLY BUILT node back
// (`badExpr(comp, result)`), so § droppedCall14's child unwrap already recovers
// it, and only the CONCATENATION — the one path that hands back an EMPTIED
// container — loses anything.  Every non-concat cell here must be RIGHT on
// BOTH binaries.
// MEASUREMENT ONLY.
package pc160;
  class basec160;
    function new(string name="x"); endfunction
    function string gn(string s="q"); return s; endfunction
  endclass

  class holdc160 #(type T=int) extends basec160;
    static string sc = "";
    int ic;
    basec160 bc;

    // c1 assignment Rhs, BARE (no concat)
    function void c1(); T t; sc = t.gt();                          endfunction
    // c2 CONCAT operand                              <- the only broken one
    function void c2(); T t; sc = {"[", t.gt(), "]"};              endfunction
    // c3 BINARY operand
    function void c3(); T t; ic = 1 + t.sz();                      endfunction
    // c4 TERNARY arm
    function void c4(); T t; sc = (ic == 0) ? t.gt() : "z";        endfunction
    // c5 CALL argument
    function void c5(); T t; sc = bc.gn(t.gt());                   endfunction
    // c6 CONDITION
    function void c6(); T t; if (t.sz() == 0) sc = "q";            endfunction
    // c7 RETURN value
    function string c7(); T t; return t.gt();                      endfunction
    // c8 CASE selector
    function void c8(); T t; case (t.sz()) 0: sc = "a"; default: sc = "b"; endcase endfunction
    // c9 SYSTEM-call argument
    function void c9(); T t; $display("%s", t.gt());               endfunction
    // c10 a STATEMENT of its own
    function void c10(); T t; t.gt();                              endfunction
  endclass
endpackage

module topc160;
  initial $display("hi");
endmodule
