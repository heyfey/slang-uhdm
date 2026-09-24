// r10uvm162 grid, arm E — WHERE THE REJECTED CONCATENATION SITS.
// The new compound operands must be recovered wherever the bad concatenation
// itself is emitted, and nowhere else.  Each context holds the SAME ternary
// (`h == null ? "null" : h.gname()`), once in an ACCEPTED concatenation and
// once in a REJECTED one.  MEASUREMENT ONLY.
package pe162;
  class basee162;
    function new(string name="x"); endfunction
    function string gname(); return "g"; endfunction
    function void sink(string a); endfunction
  endclass

  class holde162 #(type T=int) extends basee162;
    static string sres = "";
    string prop;
    basee162 bh;

    // e1 — ASSIGNMENT Rhs (the corpus context).
    function void ok_e1();      sres = {"[", bh == null ? "n" : bh.gname(), "]"};                 endfunction
    function void bd_e1(); T t; sres = {"[", bh == null ? "n" : bh.gname(), "]", t.gt()};         endfunction
    // e2 — a CONCAT OPERAND of an outer concatenation.
    function void ok_e2();      sres = {"<", {"[", bh == null ? "n" : bh.gname(), "]"}, ">"};     endfunction
    function void bd_e2(); T t; sres = {"<", {"[", bh == null ? "n" : bh.gname(), "]", t.gt()}, ">"}; endfunction
    // e3 — a CALL ARGUMENT.
    function void ok_e3();      sink({"[", bh == null ? "n" : bh.gname(), "]"});                  endfunction
    function void bd_e3(); T t; sink({"[", bh == null ? "n" : bh.gname(), "]", t.gt()});          endfunction
    // e4 — a RETURN value.
    function string ok_e4();      return {"[", bh == null ? "n" : bh.gname(), "]"};               endfunction
    function string bd_e4(); T t; return {"[", bh == null ? "n" : bh.gname(), "]", t.gt()};       endfunction
    // e5 — a SYSTEM-CALL argument.
    function void ok_e5();      $display({"[", bh == null ? "n" : bh.gname(), "]"});              endfunction
    function void bd_e5(); T t; $display({"[", bh == null ? "n" : bh.gname(), "]", t.gt()});      endfunction
    // e6 — an `if` CONDITION comparison.
    function void ok_e6();      if ({"[", bh == null ? "n" : bh.gname(), "]"} == "x") sres = "y"; endfunction
    function void bd_e6(); T t; if ({"[", bh == null ? "n" : bh.gname(), "]", t.gt()} == "x") sres = "y"; endfunction
    // e7 — a TERNARY ARM of an enclosing (good) ternary.
    function void ok_e7();      sres = prop == "" ? {"[", bh == null ? "n" : bh.gname(), "]"} : "z"; endfunction
    function void bd_e7(); T t; sres = prop == "" ? {"[", bh == null ? "n" : bh.gname(), "]", t.gt()} : "z"; endfunction
    // e8 — an LVALUE concatenation: the law returns above the mint (`inLhs`)
    //      and this cell must be BYTE-IDENTICAL on both binaries.
    function void ok_e8(); T t; logic a, b; {a, b} = 2'b10;                                        endfunction
    // e9 — the bad concat FIRST, a second GOOD one after it, one method.
    function void ok_e9();      sres = {"[", "k", "]"};                                            endfunction
    function void bd_e9(); T t; sres = {"[", bh == null ? "n" : bh.gname(), "]", t.gt()};
                                sres = {"[", "k", "]"};                                            endfunction
    // e10 — TWO rejected concatenations in one method, both with ternaries.
    function void ok_e10();      sres = {"[", bh == null ? "n" : bh.gname(), "]"};                  endfunction
    function void bd_e10(); T t; sres = {"[", bh == null ? "n" : bh.gname(), "]", t.gt()};
                                 sres = {"<", prop == "" ? "e" : prop, ">", t.gt()};                endfunction
    // e11 — a rejected concat INSIDE a rejected concat.
    function void ok_e11();      sres = {"[", {"<", prop == "" ? "e" : prop, ">"}, "]"};            endfunction
    function void bd_e11(); T t; sres = {"[", {"<", prop == "" ? "e" : prop, ">", t.gt()}, "]", t.gt()}; endfunction
  endclass
endpackage

module tope162;
  initial $display("hi");
endmodule
