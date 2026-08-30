// r10uvm162 grid, arm D — THE FOLD TRAPS.  R-V1's recorded trap is that golden
// CONSTANT-FOLDS a package-qualified parameter where our bound path emits a
// ref_obj; an operand the law MINTS in a shape golden folds or omits scores
// AWAY, not TOWARD.  This arm writes every foldable face the new shapes can
// reach, in an ACCEPTED concatenation (the oracle) and in a REJECTED one, so
// the law's admit set is decided by what golden actually does.
// MEASUREMENT ONLY.
package pd162;
  parameter string PKGP162 = "pp";
  parameter int    PKGN162 = 4;
  class based162;
    function new(string name="x"); endfunction
    function string gname(); return "g"; endfunction
  endclass

  class holdd162 #(type T=int, string FLD="f") extends based162;
    localparam string LP162 = "lp";
    localparam int    LN162 = 3;
    static string sres = "";
    int i;
    string prop;
    based162 bh;

    // d1 — a NEGATED literal (`-1`): does golden fold it into one constant?
    function void ok_d1();      sres = {"[", (i == -1) ? "a" : "b", "]"};                endfunction
    function void bd_d1(); T t; sres = {"[", (i == -1) ? "a" : "b", "]", t.gt()};        endfunction
    // d2 — a CONSTANT ARITHMETIC expression (`1 + 2`).
    function void ok_d2();      sres = {"[", (i == 1 + 2) ? "a" : "b", "]"};             endfunction
    function void bd_d2(); T t; sres = {"[", (i == 1 + 2) ? "a" : "b", "]", t.gt()};     endfunction
    // d3 — a CONSTANT-PREDICATE ternary (`1 ? "a" : "b"`).
    function void ok_d3();      sres = {"[", 1 ? "a" : "b", "]"};                        endfunction
    function void bd_d3(); T t; sres = {"[", 1 ? "a" : "b", "]", t.gt()};                endfunction
    // d4 — a LOCAL parameter operand (measured NOT folded in arm B; the control).
    function void ok_d4();      sres = {"[", (i == LN162) ? "a" : "b", "]"};             endfunction
    function void bd_d4(); T t; sres = {"[", (i == LN162) ? "a" : "b", "]", t.gt()};     endfunction
    // d5 — an UNQUALIFIED package parameter (same package, no `::`).
    function void ok_d5();      sres = {"[", (i == PKGN162) ? "a" : "b", "]"};           endfunction
    function void bd_d5(); T t; sres = {"[", (i == PKGN162) ? "a" : "b", "]", t.gt()};   endfunction
    // d6 — a PACKAGE-QUALIFIED parameter (R-V1's trap) INSIDE a ternary arm.
    function void ok_d6();      sres = {"[", prop == "" ? pd162::PKGP162 : prop, "]"};   endfunction
    function void bd_d6(); T t; sres = {"[", prop == "" ? pd162::PKGP162 : prop, "]", t.gt()}; endfunction
    // d7 — a REPLICATION whose count is a package-qualified parameter.
    function void ok_d7();      sres = {"[", {pd162::PKGN162{"x"}}, "]"};                endfunction
    function void bd_d7(); T t; sres = {"[", {pd162::PKGN162{"x"}}, "]", t.gt()};        endfunction
    // d8 — a CLASS TYPE PARAMETER as a ternary arm.
    function void ok_d8();      sres = {"[", prop == "" ? FLD : "z", "]"};               endfunction
    function void bd_d8(); T t; sres = {"[", prop == "" ? FLD : "z", "]", t.gt()};       endfunction
    // d9 — a STRING CONCATENATION of two literals nested in a ternary arm.
    function void ok_d9();      sres = {"[", prop == "" ? {"x", "y"} : prop, "]"};       endfunction
    function void bd_d9(); T t; sres = {"[", prop == "" ? {"x", "y"} : prop, "]", t.gt()}; endfunction
    // d10 — a BARE call in a ternary arm.
    function void ok_d10();      sres = {"[", prop == "" ? gname() : prop, "]"};         endfunction
    function void bd_d10(); T t; sres = {"[", prop == "" ? gname() : prop, "]", t.gt()}; endfunction
    // d11 — a SYSTEM call operand — the law must ABSTAIN (no accepted model).
    function void ok_d11();      sres = {"[", $sformatf("%0d", i), "]"};                 endfunction
    function void bd_d11(); T t; sres = {"[", $sformatf("%0d", i), "]", t.gt()};         endfunction
    // d12 — an INDEX SELECT operand — the law must ABSTAIN.
    function void ok_d12();      sres = {"[", prop[0], "]"};                             endfunction
    function void bd_d12(); T t; sres = {"[", prop[0], "]", t.gt()};                     endfunction
    // d13 — a CAST operand — the law must ABSTAIN.
    function void ok_d13();      sres = {"[", string'(prop), "]"};                       endfunction
    function void bd_d13(); T t; sres = {"[", string'(prop), "]", t.gt()};               endfunction
    // d14 — `this.prop` — the dotted-pair shape with the `this` keyword.
    function void ok_d14();      sres = {"[", this.prop, "]"};                           endfunction
    function void bd_d14(); T t; sres = {"[", this.prop, "]", t.gt()};                   endfunction
    // d15 — the CORPUS FACE: twelve operands, two of them ternaries holding a
    //       null comparison, a string constant and a dotted call
    //       (uvm_registry.svh:558-570, uvm_pkg.sv:14061-14064).
    function void ok_d15(string name, based162 parent);
      based162 obj;
      sres = {"Factory did not return a ", T::base_type_name(), " of type '", T::type_name,
        "'. A component of type '", obj == null ? "null" : obj.gname(),
        "' was returned instead. Name=", name, " Parent=",
        parent==null?"null":parent.gname(), " contxt=", prop};
    endfunction
  endclass
endpackage

module topd162;
  initial $display("hi");
endmodule
