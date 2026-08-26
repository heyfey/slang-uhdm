// r10v160 arm C — WHERE THE REJECTED CONCATENATION LIVES (homes the
// implementer's arm D does not write) and HOW MANY INSTANCES exist.
// MEASUREMENT ONLY.
package pvc160;
  class basevc160;
    function new(string name="x"); endfunction
    function string gt(); return "g"; endfunction
  endclass

  // c1 a generic class with ONE explicit specialization beside its default
  class c1_160 #(type T=int) extends basevc160;
    static string s = "";
    function void m(); T t; s = {"[", t.gt(), "]"};        endfunction
  endclass
  typedef c1_160#(basevc160) c1spec_160;

  // c2 a generic class with TWO explicit specializations beside its default
  class c2_160 #(type T=int) extends basevc160;
    static string s = "";
    function void m(); T t; s = {"[", t.gt(), "]"};        endfunction
  endclass
  typedef c2_160#(basevc160) c2a_160;
  typedef c2_160#(string)    c2b_160;

  // c3 a generic class NESTED (declared after) whose method is OUT OF BODY
  //    AND STATIC
  class c3_160 #(type T=int) extends basevc160;
    static string s = "";
    extern static function void m();
  endclass
  function void c3_160::m(); T t; s = {"[", t.gt(), "]"};  endfunction

  // c4 a generic class whose bad concat is in a method DEFAULT ARGUMENT
  class c4_160 #(type T=int) extends basevc160;
    static string s = "";
    function void m(); T t; s = {"[", t.gt(), "]"};        endfunction
    function void n(); m();                                endfunction
  endclass

  // c5 a generic class whose bad concat initialises a CLASS PROPERTY
  class c5_160 #(type T=int) extends basevc160;
    static T tp;
    static string s = {"[", tp.gt(), "]"};
  endclass

  // c6 a generic FUNCTION-scope bad concat inside a FORK/JOIN block
  class c6_160 #(type T=int) extends basevc160;
    static string s = "";
    task m(); T t; fork s = {"[", t.gt(), "]"}; join_none   endtask
  endclass

  // c7 a bad concat inside a FOREACH body
  class c7_160 #(type T=int) extends basevc160;
    static string s = "";
    int q[3];
    function void m(); T t; foreach (q[i]) s = {"[", t.gt(), "]"}; endfunction
  endclass

  // c8 THREE bad concatenations in three different methods of ONE class
  class c8_160 #(type T=int) extends basevc160;
    static string s = "";
    function void m1(); T t; s = {"1", t.gt()};            endfunction
    function void m2(); T t; s = {"2", t.gt()};            endfunction
    function void m3(); T t; s = {"3", t.gt()};            endfunction
  endclass
endpackage

// c9 a bad concat in a PACKAGE FUNCTION (no class at all) — the operand is
//    bad because the function-local's type is a forward-declared class
package pvc2_160;
  typedef class fwdvc160;
  function automatic string f9();
    fwdvc160 h;
    return {"[", h.gt(), "]"};
  endfunction
endpackage

// c10 a bad concat in a MODULE (an initial block and a continuous assign)
module topvc160;
  import pvc160::*;
  string sm;
  wire [15:0] w;
  pvc160::c1spec_160 h1;
  initial begin
    sm = {"[", "x", "]"};
    $display("%s", sm);
  end
endmodule
