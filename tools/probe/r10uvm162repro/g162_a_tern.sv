// r10uvm162 grid, arm A — THE TERNARY OPERAND, FIELD BY FIELD.
//
// Every cell is written TWICE inside the same generic class: once in a
// concatenation slang ACCEPTS (`ok_*`) and once in the SAME concatenation with
// one trailing operand slang rejects (`bd_*`).  The accepted twin is the
// ORACLE — our ordinary BOUND path already produces golden's object for it —
// so a recovered operand is right exactly when it equals its own accepted twin.
// MEASUREMENT ONLY.
package pa162;
  parameter string PKGP162 = "pp";
  class basea162;
    function new(string name="x"); endfunction
    function string gname(); return "g"; endfunction
  endclass

  class holda162 #(type T=int, string FLD="f") extends basea162;
    localparam string LP162 = "lp";
    static string sres = "";
    string prop;
    basea162 bh;

    // a1 — THE CORPUS SHAPE: `h == null ? "lit" : h.meth()`, unparenthesised.
    function void ok_a1();      sres = {"[", bh == null ? "null" : bh.gname(), "]"};                  endfunction
    function void bd_a1(); T t; sres = {"[", bh == null ? "null" : bh.gname(), "]", t.gt()};          endfunction
    // a2 — the same with NO SPACES around the operators (the corpus writes
    //      both faces: uvm_registry.svh:566 spaced, :568 unspaced).
    function void ok_a2();      sres = {"[", bh==null?"null":bh.gname(), "]"};                        endfunction
    function void bd_a2(); T t; sres = {"[", bh==null?"null":bh.gname(), "]", t.gt()};                endfunction
    // a3 — PARENTHESISED predicate.
    function void ok_a3();      sres = {"[", (prop == "") ? "a" : "b", "]"};                          endfunction
    function void bd_a3(); T t; sres = {"[", (prop == "") ? "a" : "b", "]", t.gt()};                  endfunction
    // a4 — the WHOLE ternary parenthesised.
    function void ok_a4();      sres = {"[", (prop == "" ? "a" : "b"), "]"};                          endfunction
    function void bd_a4(); T t; sres = {"[", (prop == "" ? "a" : "b"), "]", t.gt()};                  endfunction
    // a5 — a BARE IDENTIFIER predicate (no comparison at all).
    function void ok_a5();      sres = {"[", prop ? "a" : "b", "]"};                                  endfunction
    function void bd_a5(); T t; sres = {"[", prop ? "a" : "b", "]", t.gt()};                          endfunction
    // a6 — `!=` instead of `==`.
    function void ok_a6();      sres = {"[", bh != null ? "a" : "b", "]"};                            endfunction
    function void bd_a6(); T t; sres = {"[", bh != null ? "a" : "b", "]", t.gt()};                    endfunction
    // a7 — each of the three POSITIONS holding a DOTTED CALL.
    function void ok_a7();      sres = {"[", bh.gname() == "" ? bh.gname() : bh.gname(), "]"};        endfunction
    function void bd_a7(); T t; sres = {"[", bh.gname() == "" ? bh.gname() : bh.gname(), "]", t.gt()}; endfunction
    // a8 — each of the three positions holding a BARE IDENTIFIER.
    function void ok_a8();      sres = {"[", prop == "" ? prop : LP162, "]"};                         endfunction
    function void bd_a8(); T t; sres = {"[", prop == "" ? prop : LP162, "]", t.gt()};                 endfunction
    // a9 — each of the three positions holding a `::`-SCOPED name.
    function void ok_a9();      sres = {"[", T::tn == "" ? T::tn : T::tn, "]"};                       endfunction
    function void bd_a9(); T t; sres = {"[", T::tn == "" ? T::tn : T::tn, "]", t.gt()};               endfunction
    // a10 — a NESTED ternary in the FALSE arm (the shape's own recursion).
    function void ok_a10();      sres = {"[", prop == "" ? "a" : (prop == "b" ? "c" : "d"), "]"};      endfunction
    function void bd_a10(); T t; sres = {"[", prop == "" ? "a" : (prop == "b" ? "c" : "d"), "]", t.gt()}; endfunction
    // a11 — a NESTED ternary in the PREDICATE.
    function void ok_a11();      sres = {"[", (prop == "" ? 1 : 0) ? "a" : "b", "]"};                  endfunction
    function void bd_a11(); T t; sres = {"[", (prop == "" ? 1 : 0) ? "a" : "b", "]", t.gt()};          endfunction
    // a12 — a ternary whose arm is a PACKAGE PARAMETER (R-V1's trap: golden
    //       may CONSTANT-FOLD a package-qualified operand).
    function void ok_a12();      sres = {"[", prop == "" ? PKGP162 : pa162::PKGP162, "]"};            endfunction
    function void bd_a12(); T t; sres = {"[", prop == "" ? PKGP162 : pa162::PKGP162, "]", t.gt()};    endfunction
    // a13 — TWO ternaries in ONE concatenation (the corpus face).
    function void ok_a13();      sres = {"[", bh == null ? "n" : bh.gname(), "|", prop == "" ? "e" : prop, "]"}; endfunction
    function void bd_a13(); T t; sres = {"[", bh == null ? "n" : bh.gname(), "|", prop == "" ? "e" : prop, "]", t.gt()}; endfunction
    // a14 — a ternary whose PREDICATE is a comparison against a STRING LITERAL
    //       on the LEFT (operand order inside the comparison).
    function void ok_a14();      sres = {"[", "" == prop ? "a" : "b", "]"};                            endfunction
    function void bd_a14(); T t; sres = {"[", "" == prop ? "a" : "b", "]", t.gt()};                    endfunction
    // a15 — a NEGATIVE CONTROL: the ternary in an ACCEPTED concat only (no
    //       `bd_` twin) — it must be byte-identical on both binaries.
    function void ok_a15();      sres = {"[", prop == "" ? "a" : "b", "]", "!"};                       endfunction
  endclass
endpackage

module topa162;
  initial $display("hi");
endmodule
