// r10uvm162 grid, arm B — THE OTHER FOUR UNMODELLED SHAPES of r10uvm160's R1,
// plus the sub-operand kinds a ternary can hold.  Same ORACLE construction as
// arm A: `ok_*` is the ACCEPTED twin, `bd_*` the SAME concatenation with one
// trailing operand slang rejects.  MEASUREMENT ONLY.
package pb162;
  parameter string PKGP162 = "pp";
  parameter int    RC162   = 2;
  class baseb162;
    function new(string name="x"); endfunction
    function string gname(); return "g"; endfunction
    function string gname2(string a); return a; endfunction
  endclass

  class holdb162 #(type T=int, string FLD="f") extends baseb162;
    localparam string LP162 = "lp";
    static string sres = "";
    string prop;
    baseb162 bh;

    // b1 — a BARE call, no arguments.
    function void ok_b1();      sres = {"[", gname(), "]"};                       endfunction
    function void bd_b1(); T t; sres = {"[", gname(), "]", t.gt()};               endfunction
    // b2 — a BARE call WITH an argument.
    function void ok_b2();      sres = {"[", gname2("z"), "]"};                   endfunction
    function void bd_b2(); T t; sres = {"[", gname2("z"), "]", t.gt()};           endfunction
    // b3 — a NESTED concatenation.
    function void ok_b3();      sres = {"[", {"x", "y"}, "]"};                    endfunction
    function void bd_b3(); T t; sres = {"[", {"x", "y"}, "]", t.gt()};            endfunction
    // b4 — a NESTED concatenation holding a TERNARY.
    function void ok_b4();      sres = {"[", {"x", prop == "" ? "y" : "z"}, "]"};  endfunction
    function void bd_b4(); T t; sres = {"[", {"x", prop == "" ? "y" : "z"}, "]", t.gt()}; endfunction
    // b5 — a REPLICATION with a CONSTANT count.
    function void ok_b5();      sres = {"[", {2{"x"}}, "]"};                      endfunction
    function void bd_b5(); T t; sres = {"[", {2{"x"}}, "]", t.gt()};              endfunction
    // b6 — a REPLICATION with a PACKAGE-PARAMETER count.
    function void ok_b6();      sres = {"[", {RC162{"x"}}, "]"};                  endfunction
    function void bd_b6(); T t; sres = {"[", {RC162{"x"}}, "]", t.gt()};          endfunction
    // b7 — a call whose ACTUAL is itself a call.
    function void ok_b7();      sres = {"[", bh.gname2(bh.gname()), "]"};         endfunction
    function void bd_b7(); T t; sres = {"[", bh.gname2(bh.gname()), "]", t.gt()}; endfunction
    // b8 — an INTEGER literal operand.
    function void ok_b8();      sres = {"[", 8'd65, "]"};                         endfunction
    function void bd_b8(); T t; sres = {"[", 8'd65, "]", t.gt()};                 endfunction
    // b9 — a UNARY `!` operand.
    function void ok_b9();      sres = {"[", (!prop) ? "a" : "b", "]"};           endfunction
    function void bd_b9(); T t; sres = {"[", (!prop) ? "a" : "b", "]", t.gt()};   endfunction
    // b10 — the BINARY OPERATOR SET, one ternary predicate per operator.
    function void ok_b10();      sres = {"[", (prop != "") ? "a" : "b", "]"};      endfunction
    function void bd_b10(); T t; sres = {"[", (prop != "") ? "a" : "b", "]", t.gt()}; endfunction
    function void ok_b11();      sres = {"[", (prop == "" && bh == null) ? "a" : "b", "]"}; endfunction
    function void bd_b11(); T t; sres = {"[", (prop == "" && bh == null) ? "a" : "b", "]", t.gt()}; endfunction
    function void ok_b12();      sres = {"[", (RC162 > 1) ? "a" : "b", "]"};       endfunction
    function void bd_b12(); T t; sres = {"[", (RC162 > 1) ? "a" : "b", "]", t.gt()}; endfunction
    // b13 — a DOTTED NAME (a member select) as a ternary arm.
    function void ok_b13();      sres = {"[", prop == "" ? bh.gname() : prop, "]"}; endfunction
    function void bd_b13(); T t; sres = {"[", prop == "" ? bh.gname() : prop, "]", t.gt()}; endfunction
    // b14 — a `::`-SCOPED CALL as a ternary arm (the corpus's
    //       `Tcreator::base_type_name()` face).
    function void ok_b14();      sres = {"[", prop == "" ? FLD : LP162, "]"};      endfunction
    function void bd_b14(); T t; sres = {"[", prop == "" ? FLD : LP162, "]", t.gt()}; endfunction
    // b15 — a PACKAGE-QUALIFIED parameter operand (R-V1's recorded trap:
    //       golden CONSTANT-FOLDS it, and our BOUND path does not).
    function void ok_b15();      sres = {"[", pb162::PKGP162, "]"};                endfunction
    function void bd_b15(); T t; sres = {"[", pb162::PKGP162, "]", t.gt()};        endfunction
  endclass
endpackage

module topb162;
  initial $display("hi");
endmodule
