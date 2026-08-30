// r10v162 (ADVERSARIAL VERIFIER) arm 1 — THE FACE THE IMPLEMENTER'S GRID NEVER
// WRITES: the UNBINDABLE call sitting INSIDE the compound shape, not beside it.
//
// Every implementer cell puts `t.gt()` as a SEPARATE TRAILING operand, so the
// compound operands it recursed into were always fully bindable.  Here the
// silently-bad call is the ternary's own condition / true arm / false arm, the
// nested concat's own member, and the replication's own body — the exact
// places the new recursion mints an object for something slang could not bind.
//
// Naming is deliberately UNLIKE the implementer's (no a1/b1/c1 grid, mixed
// case, non-sequential numbers) so an arm cannot pass by agreeing with a
// self-confirming layout.  MEASUREMENT ONLY.
package Qx7_pkg;
  parameter string QPARM = "qq";

  class Widget7;
    function new(string nm = "w"); endfunction
    function string label(); return "L"; endfunction
    function string tag();   return "T"; endfunction
  endclass

  class Holder7 #(type ELEM = int);
    static string acc = "";
    string field;
    Widget7 wg;
    ELEM el;

    // --- the bad call in each ternary POSITION -----------------------------
    // 41: condition
    function void bd41(); acc = {"<", el.zap() == "" ? "y" : "n", ">"}; endfunction
    // 42: true arm
    function void bd42(); acc = {"<", field == "" ? el.zap() : "n", ">"}; endfunction
    // 43: false arm
    function void bd43(); acc = {"<", field == "" ? "y" : el.zap(), ">"}; endfunction
    // 44: all three
    function void bd44(); acc = {"<", el.zap() == el.zap() ? el.zap() : el.zap(), ">"}; endfunction

    // --- the bad call inside the other compounds ---------------------------
    // 45: nested concat member
    function void bd45(); acc = {"<", {"a", el.zap()}, ">"}; endfunction
    // 46: nested concat two deep
    function void bd46(); acc = {"<", {"a", {"b", el.zap()}}, ">"}; endfunction
    // 47: replication body
    function void bd47(); acc = {"<", {2{el.zap()}}, ">"}; endfunction
    // 48: binary operand
    function void bd48(); acc = {"<", el.zap() == "q" ? "y" : "n", ">"}; endfunction
    // 49: ternary inside a nested concat inside a ternary
    function void bd49(); acc = {"<", field == "" ? {"a", wg.label() == "" ? "p" : el.zap()} : "n", ">"}; endfunction

    // --- ACCEPTED TWINS: the same written shape with a BINDABLE call --------
    function void ok41(); acc = {"<", wg.label() == "" ? "y" : "n", ">"}; endfunction
    function void ok42(); acc = {"<", field == "" ? wg.label() : "n", ">"}; endfunction
    function void ok43(); acc = {"<", field == "" ? "y" : wg.label(), ">"}; endfunction
    function void ok45(); acc = {"<", {"a", wg.label()}, ">"}; endfunction
    function void ok46(); acc = {"<", {"a", {"b", wg.label()}}, ">"}; endfunction
    function void ok47(); acc = {"<", {2{wg.label()}}, ">"}; endfunction
  endclass
endpackage

module Top_Qx7;
  initial $display("qx7");
endmodule
