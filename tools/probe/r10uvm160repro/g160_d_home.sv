// r10uvm160 grid, arm D — WHERE THE REJECTED CONCATENATION LIVES.
// The same `{"[", <bad>, "]"}` in every home a class body can have, plus the
// two controls that must NOT move: a specialization whose type argument is a
// REAL class (nothing is bad there) and a NON-parameterized class (likewise).
// MEASUREMENT ONLY.
package pd160;
  class based160;
    function new(string name="x"); endfunction
    function string gt(); return "g"; endfunction
    function string fld160(); return "f"; endfunction
  endclass

  // D1 one type parameter, DEFAULT specialization: in-body method
  class d1_160 #(type T=int) extends based160;
    static string sd = "";
    function void m(); T t; sd = {"[", t.gt(), "]"};        endfunction
  endclass
  // D2 the same, OUT-OF-BODY method
  class d2_160 #(type T=int) extends based160;
    static string sd = "";
    extern function void m();
  endclass
  function void d2_160::m(); T t; sd = {"[", t.gt(), "]"};  endfunction
  // D3 the same, a TASK
  class d3_160 #(type T=int) extends based160;
    static string sd = "";
    task m(); T t; sd = {"[", t.gt(), "]"};                 endtask
  endclass
  // D4 the same, a STATIC method
  class d4_160 #(type T=int) extends based160;
    static string sd = "";
    static function void m(); T t; sd = {"[", t.gt(), "]"}; endfunction
  endclass
  // (D5, the CONSTRUCTOR home, is deliberately NOT here: SURELOG itself
  //  reports `Unresolved hierarchical reference "t.gt"` for a rejected
  //  concatenation written inside `new`, in the ELAB view only, so a golden
  //  built from it is not a golden this grid can score.  The corpus reaches
  //  the constructor home nowhere.)
  // D6 TWO type parameters
  class d6_160 #(type T=int, type V=int) extends based160;
    static string sd = "";
    function void m(); T t; V v; sd = {"[", t.gt(), v.gt(), "]"}; endfunction
  endclass
  // D7 CONTROL — a specialization whose argument is a REAL class: nothing is
  //    bad, golden and both our binaries must agree and STAY agreed.
  class d7_160 #(type T=based160) extends based160;
    static string sd = "";
    function void m(); T t; sd = {"[", t.gt(), "]"};        endfunction
  endclass
  // D8 CONTROL — a NON-parameterized class: likewise.
  class d8_160 extends based160;
    static string sd = "";
    function void m(); based160 t; sd = {"[", t.gt(), "]"}; endfunction
  endclass
  // D9 an EXPLICIT specialization of D1 with a class, beside D1's default —
  //    both listings exist in ONE database.
  typedef d1_160#(based160) d9_160;
endpackage

module topd160;
  pd160::d9_160 h9;
  initial $display("hi");
endmodule
