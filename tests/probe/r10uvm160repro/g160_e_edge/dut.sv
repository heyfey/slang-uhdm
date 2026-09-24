// r10uvm160 grid, arm E — COUNTS, ORDER AND EDGES.
// How many bad operands, WHERE in the list, how many rejected concatenations
// per method and per class, and the shapes the law must REFUSE: an LVALUE
// concatenation, a REPLICATION, an UNPACKED-ARRAY concatenation, a nested
// rejected concatenation inside a rejected one.
// MEASUREMENT ONLY.
package pe160;
  class basee160;
    function new(string name="x"); endfunction
    function string gn(); return "g"; endfunction
  endclass

  class holde160 #(type T=int) extends basee160;
    static string se = "";
    string p1, p2;
    bit [7:0] v1, v2;
    string qa[2];

    // e1 the bad operand FIRST
    function void e1(); T t; se = {t.gt(), "b"};                        endfunction
    // e2 the bad operand LAST
    function void e2(); T t; se = {"a", t.gt()};                        endfunction
    // e3 TWO bad operands
    function void e3(); T t; se = {"a", t.gt(), "b", t.gt()};           endfunction
    // e4 THREE operands, all bad
    function void e4(); T t; se = {t.gt(), t.g2(), t.g3()};             endfunction
    // e5 ONE operand, bad
    function void e5(); T t; se = {t.gt()};                             endfunction
    // e6 TWO rejected concatenations in ONE method
    function void e6(); T t; se = {"a", t.gt()}; se = {"b", t.gt()};    endfunction
    // e7 a rejected concatenation NESTED in a rejected one
    function void e7(); T t; se = {"a", {"b", t.gt()}, "c"};            endfunction
    // e8 an LVALUE concatenation with a bad element — the law REFUSES lvalues
    function void e8(); T t; {v1, v2} = 16'h1234; se = {"a", t.gt()};   endfunction
    // e9 a REPLICATION operand beside a bad one
    function void e9(); T t; se = {{2{"x"}}, t.gt()};                   endfunction
    // e10 an UNPACKED-ARRAY concatenation with a bad element
    function void e10(); T t; qa = '{"a", "b"}; se = {"a", t.gt()};     endfunction
    // e11 the bad operand inside a concatenation used as a CALL ARGUMENT
    //     (the uvm_utils shape: the concat's parent is a method_func_call)
    function void e11(); T t; void'(gn2({"a", t.gt(), "b"}));           endfunction
    function string gn2(string s); return s;                            endfunction
    // e12 ACCEPTED control in the same class — must stay RIGHT
    function void e12(); se = {"a", p1, "b", p2};                       endfunction
  endclass

  // e13 a SECOND generic class in the same database, also rejected
  class holde2_160 #(type W=int);
    static string s2 = "";
    function void m(); W w; s2 = {"<", w.gt(), ">"};                    endfunction
  endclass
endpackage

module tope160;
  initial $display("hi");
endmodule
