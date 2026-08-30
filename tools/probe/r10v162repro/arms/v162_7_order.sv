// r10v162 arm 7 — ORDER AND POSITION.  Every implementer cell puts the
// unbindable call LAST; here it is FIRST, SECOND, in the MIDDLE and TWICE, and
// the compound operands are written in varying orders around it.  An arm that
// only ever writes one order is self-confirming (RESUME §9).
// Also: a concatenation whose ONLY operand is the compound, a concatenation of
// exactly two compounds, and the reduced corpus witness written with the
// operands in a DIFFERENT order from `uvm_registry.svh`.
// MEASUREMENT ONLY.
package Ord7_pkg;
  parameter string OP7 = "op";

  class Ping7;
    function new(string nm = "p"); endfunction
    function string beat(); return "b"; endfunction
  endclass

  class Line7 #(type MARK = int, type OTHER = int);
    static string out = "";
    string s;
    Ping7 pg;
    MARK  mk;
    OTHER ot;

    // the bad call FIRST
    function void p1(); out = {mk.nix(), "|", s=="" ? "a" : pg.beat()}; endfunction
    // SECOND
    function void p2(); out = {"|", mk.nix(), s=="" ? "a" : pg.beat(), "|"}; endfunction
    // in the MIDDLE of six
    function void p3(); out = {"a", s=="" ? "b" : pg.beat(), mk.nix(), {2{s}}, "c", s=="" ? "d" : "e"}; endfunction
    // TWICE, from two different type parameters
    function void p4(); out = {mk.nix(), s=="" ? "a" : "b", ot.nyx()}; endfunction
    // the compound as the ONLY good operand
    function void p5(); out = {s=="" ? "a" : "b", mk.nix()}; endfunction
    // exactly two compounds
    function void p6(); out = {s=="" ? "a" : "b", {3{s}}, mk.nix()}; endfunction
    // the corpus witness with the operand order REVERSED
    function void p7();
      out = {s, " contxt=", s=="" ? "null" : pg.beat(), " Parent=", s, " Name=",
             "' was returned instead. ", s=="" ? "null" : pg.beat(),
             "'. A component of type '", OP7, " of type '", "Factory did not return a ",
             mk.nix()};
    endfunction
    // ACCEPTED TWINS
    function void q3(); out = {"a", s=="" ? "b" : pg.beat(), {2{s}}, "c", s=="" ? "d" : "e"}; endfunction
    function void q6(); out = {s=="" ? "a" : "b", {3{s}}}; endfunction
    function void q7();
      out = {s, " contxt=", s=="" ? "null" : pg.beat(), " Parent=", s, " Name=",
             "' was returned instead. ", s=="" ? "null" : pg.beat(),
             "'. A component of type '", OP7, " of type '", "Factory did not return a "};
    endfunction
  endclass
endpackage

module Top_Ord7;
  initial $display("ord7");
endmodule
