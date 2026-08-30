// r10v162 arm 2 — THE SHAPE FACES THE TASK NAMES, one per line, each with the
// trailing unbindable call that empties the concatenation.
//
//   a ternary of ternaries (all three positions)
//   a bare call with 0, 1 and 3 arguments
//   a nested concat one and two deep
//   a replication with a CONSTANT, a PARAMETER and an EXPRESSION count
//   a call whose actual is a call
//   a package-qualified PARAMETER operand (golden folds it: stay abstained or
//     folded — never a minted ref_obj at depth > 0)
//   a system call operand / a cast operand / a select operand
//
// MEASUREMENT ONLY.
package Zed9_pkg;
  parameter string ZP = "zz";
  parameter int    ZN = 4;

  class Node9;
    function new(string nm = "n"); endfunction
    function string nm0();                       return "0"; endfunction
    function string nm1(string a);               return "1"; endfunction
    function string nm3(string a, string b, int c); return "3"; endfunction
  endclass

  class Bag9 #(type KIND = int, string SZ = "s");
    static string sink = "";
    string txt;
    string arr [4];
    byte   bts [8];
    int    idx;
    Node9  nd;
    KIND   kk;

    // ternary of ternaries, every position
    function void bdA(); sink = {"(", (txt=="" ? "a" : "b")=="" ? (txt=="c" ? "d" : "e") : (txt=="f" ? "g" : "h"), ")", kk.oops()}; endfunction
    // bare calls: 0, 1 and 3 arguments
    function void bdB(); sink = {"(", nm0f(), ")", kk.oops()}; endfunction
    function void bdC(); sink = {"(", nm1f("x"), ")", kk.oops()}; endfunction
    function void bdD(); sink = {"(", nm3f("x", "y", 7), ")", kk.oops()}; endfunction
    // nested concat one and two deep
    function void bdE(); sink = {"(", {"m", txt}, ")", kk.oops()}; endfunction
    function void bdF(); sink = {"(", {"m", {"n", txt}}, ")", kk.oops()}; endfunction
    // replication counts: constant, parameter, expression
    function void bdG(); sink = {"(", {3{txt}}, ")", kk.oops()}; endfunction
    function void bdH(); sink = {"(", {ZN{txt}}, ")", kk.oops()}; endfunction
    function void bdI(); sink = {"(", {(ZN+1){txt}}, ")", kk.oops()}; endfunction
    // a call whose ACTUAL is a call
    function void bdJ(); sink = {"(", nd.nm1(nd.nm0()), ")", kk.oops()}; endfunction
    // a PACKAGE-QUALIFIED PARAMETER, top level and inside a ternary and a count
    function void bdK(); sink = {"(", Zed9_pkg::ZP, ")", kk.oops()}; endfunction
    function void bdL(); sink = {"(", txt=="" ? Zed9_pkg::ZP : "b", ")", kk.oops()}; endfunction
    function void bdM(); sink = {"(", {Zed9_pkg::ZN{txt}}, ")", kk.oops()}; endfunction
    // system call / cast / select operands (bare and inside a ternary)
    function void bdN(); sink = {"(", $sformatf("%0d", idx), ")", kk.oops()}; endfunction
    function void bdO(); sink = {"(", txt=="" ? $sformatf("%0d", idx) : "b", ")", kk.oops()}; endfunction
    function void bdP(); sink = {"(", string'(bts), ")", kk.oops()}; endfunction
    function void bdQ(); sink = {"(", txt=="" ? string'(bts) : "b", ")", kk.oops()}; endfunction
    function void bdR(); sink = {"(", arr[1], ")", kk.oops()}; endfunction
    function void bdS(); sink = {"(", txt=="" ? arr[1] : "b", ")", kk.oops()}; endfunction
    // `this.` member, bare and nested
    function void bdT(); sink = {"(", this.txt, ")", kk.oops()}; endfunction
    function void bdU(); sink = {"(", txt=="" ? this.txt : "b", ")", kk.oops()}; endfunction

    // ACCEPTED TWINS (the oracle for every one of the above)
    function void okA(); sink = {"(", (txt=="" ? "a" : "b")=="" ? (txt=="c" ? "d" : "e") : (txt=="f" ? "g" : "h"), ")"}; endfunction
    function void okB(); sink = {"(", nm0f(), ")"}; endfunction
    function void okC(); sink = {"(", nm1f("x"), ")"}; endfunction
    function void okD(); sink = {"(", nm3f("x", "y", 7), ")"}; endfunction
    function void okE(); sink = {"(", {"m", txt}, ")"}; endfunction
    function void okF(); sink = {"(", {"m", {"n", txt}}, ")"}; endfunction
    function void okG(); sink = {"(", {3{txt}}, ")"}; endfunction
    function void okH(); sink = {"(", {ZN{txt}}, ")"}; endfunction
    function void okI(); sink = {"(", {(ZN+1){txt}}, ")"}; endfunction
    function void okJ(); sink = {"(", nd.nm1(nd.nm0()), ")"}; endfunction
    function void okK(); sink = {"(", Zed9_pkg::ZP, ")"}; endfunction
    function void okL(); sink = {"(", txt=="" ? Zed9_pkg::ZP : "b", ")"}; endfunction
    function void okM(); sink = {"(", {Zed9_pkg::ZN{txt}}, ")"}; endfunction
    function void okN(); sink = {"(", $sformatf("%0d", idx), ")"}; endfunction
    function void okR(); sink = {"(", arr[1], ")"}; endfunction
    function void okT(); sink = {"(", this.txt, ")"}; endfunction

    function string nm0f();                          return "0"; endfunction
    function string nm1f(string a);                  return "1"; endfunction
    function string nm3f(string a, string b, int c); return "3"; endfunction
  endclass
endpackage

module Top_Zed9;
  initial $display("zed9");
endmodule
