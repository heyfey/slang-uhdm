// r10v162 arm 3 — WHERE THE REJECTED CONCATENATION SITS.  One compound-operand
// concatenation per context: assignment Rhs, concat operand, call argument,
// return value, `if` condition, case item, loop condition, a system-task
// argument, and an LVALUE concat control that must NOT move.
// MEASUREMENT ONLY.
package Ctx3_pkg;
  class Emit3;
    function new(string nm = "e"); endfunction
    function string txt(); return "t"; endfunction
    function void take(string s); endfunction
    function string echo(string s); return s; endfunction
  endclass

  class Site3 #(type PL = int);
    static string bin = "";
    string who;
    bit    b0, b1, b2, b3;
    Emit3  em;
    PL     pl;

    // assignment Rhs
    function void c01(); bin = {"[", who=="" ? "a" : em.txt(), "]", pl.nope()}; endfunction
    // operand of ANOTHER concatenation
    function void c02(); bin = {"pre", {"[", who=="" ? "a" : em.txt(), "]", pl.nope()}}; endfunction
    // call argument
    function void c03(); em.take({"[", who=="" ? "a" : em.txt(), "]", pl.nope()}); endfunction
    // return value
    function string c04(); return {"[", who=="" ? "a" : em.txt(), "]", pl.nope()}; endfunction
    // `if` condition
    function void c05(); if ({"[", who=="" ? "a" : em.txt(), "]", pl.nope()} != "") bin = "y"; endfunction
    // case item / case expression
    function void c06();
      case ({"[", who=="" ? "a" : em.txt(), "]", pl.nope()})
        "x": bin = "x";
        default: bin = "d";
      endcase
    endfunction
    function void c07();
      case (who)
        {"[", who=="" ? "a" : em.txt(), "]", pl.nope()}: bin = "hit";
        default: bin = "miss";
      endcase
    endfunction
    // while condition
    function void c08(); while ({"[", who=="" ? "a" : em.txt(), "]", pl.nope()} == "zzz") bin = "w"; endfunction
    // system-task argument
    function void c09(); $display("%s", {"[", who=="" ? "a" : em.txt(), "]", pl.nope()}); endfunction
    // ternary arm at STATEMENT level
    function void c10(); bin = (who=="") ? {"[", who=="" ? "a" : em.txt(), "]", pl.nope()} : "z"; endfunction
    // TWO rejected concatenations in one method
    function void c11();
      bin = {"[", who=="" ? "a" : em.txt(), "]", pl.nope()};
      bin = {"(", {2{who}}, ")", pl.nope()};
    endfunction
    // a rejected concat INSIDE a rejected concat
    function void c12(); bin = {"o", {"i", who=="" ? "a" : em.txt(), pl.nope()}, pl.nope()}; endfunction
    // the LVALUE CONTROL — must not move
    function void c13(); {b3, b2, b1, b0} = 4'b1010; endfunction
    function void c14(); {b1, b0} = {b0, b1}; endfunction
    // a good concatenation AFTER a bad one in the same method
    function void c15();
      bin = {"[", who=="" ? "a" : em.txt(), "]", pl.nope()};
      bin = {"good", who, em.txt()};
    endfunction
  endclass
endpackage

module Top_Ctx3;
  initial $display("ctx3");
endmodule
