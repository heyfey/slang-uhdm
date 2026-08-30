// r10v162 arm 9 — THE EXOTIC SLOTS: a replication COUNT that is itself a
// compound, a compound under a macro argument (§ 160's R2 window), the
// `direct` flag's own corners, and operands whose kind neither side may model
// (`$bits`, a queue/array method, a `std::` name, a streaming concat, an
// assignment pattern, an inside-expression, a `with` clause).
//
// The law may ABSTAIN on any of these.  What it must not do is mint a partial
// operand vector, change rc, or move a cell golden and our pristine agreed on.
// MEASUREMENT ONLY.
`define WRAP9(x) $display("%s", x)
`define CAT9(a,b) {a, b}

package Exo9_pkg;
  parameter int EN = 2;

  class Bit9;
    function new(string nm = "b"); endfunction
    function string sn(); return "s"; endfunction
  endclass

  class Odd9 #(type PIN = int);
    static string box = "";
    string u;
    int    qq [$];
    int    aa [4];
    Bit9   bb;
    PIN    pn;

    // a replication COUNT that is a TERNARY
    function void x01(); box = {"[", {(u=="" ? 2 : 3){u}}, "]", pn.vanish()}; endfunction
    // a replication COUNT that is a BINARY operation
    function void x02(); box = {"[", {(EN+1){u}}, "]", pn.vanish()}; endfunction
    // a replication whose BODY is a nested replication
    function void x03(); box = {"[", {2{{3{u}}}}, "]", pn.vanish()}; endfunction
    // a nested concat holding a replication holding a ternary
    function void x04(); box = {"[", {"m", {2{u=="" ? "a" : "b"}}}, "]", pn.vanish()}; endfunction
    // a compound operand under a MACRO argument (§ 160's R2 span window)
    function void x05(); `WRAP9({"[", u=="" ? "a" : bb.sn(), "]", pn.vanish()}); endfunction
    // a MACRO-BUILT concatenation
    function void x06(); box = `CAT9(u=="" ? "a" : "b", pn.vanish()); endfunction
    // $bits / array method / streaming / assignment pattern / inside
    function void x07(); box = {"[", $sformatf("%0d", $bits(u)), "]", pn.vanish()}; endfunction
    function void x08(); box = {"[", $sformatf("%0d", qq.size()), "]", pn.vanish()}; endfunction
    function void x09(); box = {"[", u=="" ? $sformatf("%0d", aa[2]) : "b", "]", pn.vanish()}; endfunction
    function void x10(); box = {"[", (u inside {"a", "b"}) ? "y" : "n", "]", pn.vanish()}; endfunction
    // a ternary whose arms are STRING CONCATENATIONS of unequal depth
    function void x11(); box = {"[", u=="" ? {"a", {"b", {"c", u}}} : {"d"}, "]", pn.vanish()}; endfunction
    // a literal directly under a nested concat directly under a ternary
    function void x12(); box = {"[", u=="" ? {"a", 7} : "b", "]", pn.vanish()}; endfunction
    // a literal directly under a replication count nested in a ternary
    function void x13(); box = {"[", u=="" ? {2{"a"}} : "b", "]", pn.vanish()}; endfunction

    // ACCEPTED TWINS
    function void y01(); box = {"[", {(u=="" ? 2 : 3){u}}, "]"}; endfunction
    function void y02(); box = {"[", {(EN+1){u}}, "]"}; endfunction
    function void y03(); box = {"[", {2{{3{u}}}}, "]"}; endfunction
    function void y04(); box = {"[", {"m", {2{u=="" ? "a" : "b"}}}, "]"}; endfunction
    function void y05(); `WRAP9({"[", u=="" ? "a" : bb.sn(), "]"}); endfunction
    function void y07(); box = {"[", $sformatf("%0d", $bits(u)), "]"}; endfunction
    function void y10(); box = {"[", (u inside {"a", "b"}) ? "y" : "n", "]"}; endfunction
    function void y11(); box = {"[", u=="" ? {"a", {"b", {"c", u}}} : {"d"}, "]"}; endfunction
    function void y12(); box = {"[", u=="" ? {"a", 7} : "b", "]"}; endfunction
    function void y13(); box = {"[", u=="" ? {2{"a"}} : "b", "]"}; endfunction
  endclass
endpackage

module Top_Exo9;
  initial $display("exo9");
endmodule
