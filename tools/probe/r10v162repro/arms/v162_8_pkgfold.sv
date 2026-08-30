// r10v162 arm 8 — THE `depth > 0` PACKAGE-PARAMETER REFUSAL, and the AST-FORCE
// it performs.  The refusal calls `comp.getPackage(first)->find(last)`, which
// is a NAME LOOKUP that ELABORATES that package's scope from inside the DEF
// emission — RESUME §9's Heisenbug window ("do not force AST binding during the
// DEF phase").  This arm puts every face of that lookup in front of it:
//
//   * a `pkg::PARAM` at depth > 0 (refused) and at the top level (§ 160's
//     landed shape (5), which must STILL be minted)
//   * a `pkg::FUNC()` and a `pkg::TYPE` and a `pkg::localparam` — a package
//     member that is NOT a parameter, so the refusal must not fire
//   * a CLASS-qualified and a TYPE-PARAMETER-qualified name that happen to
//     share their first segment's spelling with a real package
//   * a package NEVER otherwise referenced by the design, reached ONLY through
//     the refusal's lookup (the AST-force face)
//   * a package that is referenced only through a WILDCARD import
//
// Legal SV.  What must hold: identical rc on both binaries, no arm moving AWAY,
// and the top-level `::` operand still recovered.  MEASUREMENT ONLY.

// A package the design NEVER references except through the refusal's lookup.
package Untouched8;
  parameter string NEVER = "never";
  parameter int    NEVN  = 7;
  localparam string LOCL = "locl";
  typedef int word8_t;
  function string ufun(); return "u"; endfunction
endpackage

package Used8;
  parameter string UP = "up";
  parameter int    UN = 3;
  function string gfun(); return "g"; endfunction
  typedef logic [3:0] nib8_t;

  // A CLASS whose name is also a plausible qualifier.
  class Untouched8_like;
    static function string NEVER(); return "notaparam"; endfunction
  endclass

  class Fold8 #(type SEAT = int);
    static string acc = "";
    string s;
    SEAT st;

    // top level `::` PARAMETER — § 160's shape (5): must STILL be minted
    function void f01(); acc = {"[", Untouched8::NEVER, "]", st.gone()}; endfunction
    // depth > 0 inside a ternary — the refusal
    function void f02(); acc = {"[", s=="" ? Untouched8::NEVER : "b", "]", st.gone()}; endfunction
    // depth > 0 inside a nested concat
    function void f03(); acc = {"[", {"m", Untouched8::NEVER}, "]", st.gone()}; endfunction
    // depth > 0 as a replication COUNT
    function void f04(); acc = {"[", {Untouched8::NEVN{s}}, "]", st.gone()}; endfunction
    // depth > 0 inside a binary operator
    function void f05(); acc = {"[", (Untouched8::NEVER == s) ? "y" : "n", "]", st.gone()}; endfunction
    // a package FUNCTION at depth > 0 — NOT a parameter, must not be refused
    function void f06(); acc = {"[", s=="" ? Untouched8::ufun() : "b", "]", st.gone()}; endfunction
    // a package LOCALPARAM at depth > 0
    function void f07(); acc = {"[", s=="" ? Untouched8::LOCL : "b", "]", st.gone()}; endfunction
    // the SAME package used at depth 0 and depth > 0 in ONE concatenation
    function void f08(); acc = {Untouched8::NEVER, s=="" ? Untouched8::NEVER : "b", st.gone()}; endfunction
    // a CLASS-qualified name whose first segment is a class, not a package
    function void f09(); acc = {"[", s=="" ? Untouched8_like::NEVER() : "b", "]", st.gone()}; endfunction
    // a TYPE-PARAMETER-qualified name (the corpus's own face)
    function void f10(); acc = {"[", s=="" ? SEAT::tname : "b", "]", st.gone()}; endfunction
    // a package parameter reached through a wildcard import, UNQUALIFIED
    function void f11(); acc = {"[", s=="" ? UP : "b", "]", st.gone()}; endfunction
    // qualified with the package that HOLDS this class
    function void f12(); acc = {"[", s=="" ? Used8::UP : "b", "]", st.gone()}; endfunction

    // ACCEPTED TWINS
    function void g01(); acc = {"[", Untouched8::NEVER, "]"}; endfunction
    function void g02(); acc = {"[", s=="" ? Untouched8::NEVER : "b", "]"}; endfunction
    function void g04(); acc = {"[", {Untouched8::NEVN{s}}, "]"}; endfunction
    function void g06(); acc = {"[", s=="" ? Untouched8::ufun() : "b", "]"}; endfunction
    function void g07(); acc = {"[", s=="" ? Untouched8::LOCL : "b", "]"}; endfunction
    function void g11(); acc = {"[", s=="" ? UP : "b", "]"}; endfunction
    function void g12(); acc = {"[", s=="" ? Used8::UP : "b", "]"}; endfunction
  endclass
endpackage

module Top_Fold8;
  initial $display("fold8");
endmodule
