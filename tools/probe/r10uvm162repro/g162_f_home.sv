// r10uvm162 grid, arm F — WHERE THE REJECTED CONCATENATION LIVES, AND HOW
// MANY TIMES.  The population § 160 decoded is the body of a GENERIC CLASS's
// DEFAULT specialization, which nothing in the source specializes and slang
// therefore never diagnoses.  This arm writes the ternary-bearing concatenation
// in every home, and pairs it with the two CONTROLS that must NOT move: a
// specialization whose argument is a REAL class (slang binds it, so there is no
// bad concatenation at all) and a NON-parameterized class.  It also declares
// the generic class ONE, TWO and THREE times as an EXPLICIT specialization
// whose argument DOES carry the method, beside the default specialization that
// does not, so a per-instance re-emission cannot hide behind a single copy.
//
// THE ARM'S OWN FENCE, and the reason it is written this way: an explicit
// `#(int)` specialization makes SLANG REPORT the bad member access, and a
// reported error is `SLANG_REJECT` — out of the campaign's scope by decision
// (§ 160's arm A paid for this lesson).  A first cut of this arm carried
// `holdf162 #(int) i3;` and our own binary exited 3.  An arm our own tool
// refuses is not an arm that measures anything.
// MEASUREMENT ONLY.
package pf162;
  class basef162;
    function new(string name="x"); endfunction
    function string gname(); return "g"; endfunction
    function string get_type_name(); return "b"; endfunction
  endclass

  // The type argument the EXPLICIT specializations use: it HAS the method the
  // default specialization's `int` has not, so those specializations bind.
  class hasgt162;
    function string gt(); return "t"; endfunction
    function string gu(); return "u"; endfunction
  endclass

  // f1..f5 — the FIVE HOMES inside one generic class.
  class holdf162 #(type T=int) extends basef162;
    static string sres = "";
    string prop;
    basef162 bh;
    extern function void f2_oob();
    // f1 — an IN-BODY method.
    function void f1_body(); T t; sres = {"[", bh == null ? "n" : bh.gname(), "]", t.gt()}; endfunction
    // f3 — a TASK.
    task f3_task(); T t; sres = {"[", bh == null ? "n" : bh.gname(), "]", t.gt()}; endtask
    // f4 — a STATIC method.
    static function void f4_static(); T t; basef162 lb;
      sres = {"[", lb == null ? "n" : lb.gname(), "]", t.gt()}; endfunction
  endclass
  // f2 — an OUT-OF-BODY method of the same generic class.
  function void holdf162::f2_oob(); T t; sres = {"[", bh == null ? "n" : bh.gname(), "]", t.gt()}; endfunction

  // f6 — TWO type parameters.
  class twof162 #(type T=int, type U=int) extends basef162;
    static string sres = "";
    basef162 bh;
    function void f6(); T t; U u; sres = {"[", bh == null ? "n" : bh.gname(), "]", t.gt(), u.gu()}; endfunction
  endclass

  // f7 — a CONTROL: a generic class whose DEFAULT argument is a REAL class.
  //      slang BINDS `t.gname()` here, so there is no bad concatenation and no
  //      recovery; the cell must be byte-identical on both binaries.
  class realf162 #(type T=basef162) extends basef162;
    static string sres = "";
    basef162 bh;
    function void f7(); T t; sres = {"[", bh == null ? "n" : bh.gname(), "]", t.gname()}; endfunction
  endclass

  // f8 — a CONTROL: a NON-parameterized class with the same written text.
  class plainf162 extends basef162;
    static string sres = "";
    basef162 bh;
    function void f8(); sres = {"[", bh == null ? "n" : bh.gname(), "]", bh.gname()}; endfunction
  endclass
endpackage

// f9 — the generic class declared ONE, TWO and THREE times as an EXPLICIT
//      specialization that BINDS, beside the DEFAULT specialization that does
//      not, in one database.
module topf162;
  import pf162::*;
  holdf162 #(hasgt162) i1;
  holdf162 #(hasgt162) i2;
  twof162  #(hasgt162, hasgt162) i3;
  realf162 #(basef162) r1;
  plainf162            p1;
  initial $display("hi");
endmodule
