// r10v160 arm D — THE REJECTED CONCATENATION'S OWN CONTEXT.
// Where the CONCATENATION itself sits (not where the bad sub-expression sits):
// an initializer, a parameter default, a case item, a replication body, a cast
// operand, a ternary arm, a binary operand, a unary operand, an LVALUE, a
// return, an argument.  MEASUREMENT ONLY.
package pvd160;
  class basevd160;
    function new(string name="x"); endfunction
    function string gn(string s="q"); return s; endfunction
  endclass

  class holdvd160 #(type T=int) extends basevd160;
    static string sd = "";
    string p1;
    bit [7:0] v1, v2;
    int id;

    // d1 a VARIABLE-DECLARATION INITIALIZER
    function void d1(); T t; string lv = {"[", t.gt(), "]"}; sd = lv; endfunction
    // d2 a RETURN expression
    function string d2(); T t; return {"[", t.gt(), "]"};             endfunction
    // d3 a CALL ARGUMENT
    function void d3(); T t; sd = gn({"[", t.gt(), "]"});             endfunction
    // d4 a SYSTEM-call argument
    function void d4(); T t; $display("%s", {"[", t.gt(), "]"});      endfunction
    // d5 a TERNARY arm
    function void d5(); T t; sd = (id==0) ? {"[", t.gt(), "]"} : "z"; endfunction
    // d6 a BINARY operand (string comparison)
    function void d6(); T t; if ({"[", t.gt(), "]"} == "q") sd = "y"; endfunction
    // d7 a CASE selector
    function void d7(); T t;
      case ({"[", t.gt(), "]"}) "a": sd = "1"; default: sd = "2"; endcase endfunction
    // d8 a CASE ITEM expression
    function void d8(); T t;
      case (p1) {"[", t.gt(), "]"}: sd = "1"; default: sd = "2"; endcase endfunction
    // d9 an IF CONDITION
    function void d9(); T t; if ({"[", t.gt(), "]"} != "") sd = "y"; endfunction
    // d10 a REPLICATION body
    function void d10(); T t; sd = {2{ {"[", t.gt(), "]"} }};        endfunction
    // d11 a CAST operand
    function void d11(); T t; sd = string'({"[", t.gt(), "]"});      endfunction
    // d12 an LVALUE concatenation with a bad element — the law REFUSES
    function void d12(); T t; {v1, v2} = 16'h55aa; sd = {"[", t.gt(), "]"}; endfunction
    // d13 the concat NESTED inside an ACCEPTED concat
    function void d13(); T t; sd = {"<", {"[", t.gt(), "]"}, ">"};   endfunction
    // d14 a FOR-loop initialiser context
    function void d14(); T t; for (int i=0;i<1;i++) sd = {"[", t.gt(), "]"}; endfunction
    // d15 a WHILE condition
    function void d15(); T t; while ({"[", t.gt(), "]"} == "") sd = "y"; endfunction
    // d16 a UNARY operand
    function void d16(); T t; id = $bits({"[", t.gt(), "]"});        endfunction
  endclass

  // d17 a CLASS PARAMETER default that is a rejected concatenation
  class d17_160 #(type T=int, string P = "z") extends basevd160;
    static string sd = "";
    function void m(); T t; sd = {P, t.gt()};                        endfunction
  endclass
endpackage

module topvd160;
  initial $display("hi");
endmodule
