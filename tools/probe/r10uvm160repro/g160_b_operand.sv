// r10uvm160 grid, arm B — WHAT THE OTHER OPERANDS ARE.
// Twelve operand kinds, each written TWICE inside the same generic class: once
// in a concatenation slang ACCEPTS (`ok_*`) and once in the SAME concatenation
// with one trailing operand slang rejects (`bd_*`).  The accepted twin is the
// ORACLE: our ordinary bound path already produces golden's object for it, so
// a recovered operand is right exactly when it equals its own accepted twin.
// MEASUREMENT ONLY.
package pb160;
  parameter string PKGP160 = "pp";
  class baseb160;
    function new(string name="x"); endfunction
    function string gname(); return "g"; endfunction
  endclass

  class holdb160 #(type T=int, string FLD="f") extends baseb160;
    localparam string LP160 = "lp";
    static string sres = "";
    string prop;
    baseb160 bh;

    // string LITERAL
    function void ok_lit(); sres = {"[", "k", "]"};                          endfunction
    function void bd_lit(); T t; sres = {"[", "k", "]", t.gt()};             endfunction
    // class TYPE PARAMETER (a string parameter)
    function void ok_par(); sres = {"[", FLD, "]"};                          endfunction
    function void bd_par(); T t; sres = {"[", FLD, "]", t.gt()};             endfunction
    // class LOCALPARAM
    function void ok_lp();  sres = {"[", LP160, "]"};                        endfunction
    function void bd_lp();  T t; sres = {"[", LP160, "]", t.gt()};           endfunction
    // class PROPERTY
    function void ok_prp(); sres = {"[", prop, "]"};                         endfunction
    function void bd_prp(); T t; sres = {"[", prop, "]", t.gt()};            endfunction
    // METHOD LOCAL
    function void ok_loc(); string lv = "v"; sres = {"[", lv, "]"};          endfunction
    function void bd_loc(); string lv = "v"; T t; sres = {"[", lv, "]", t.gt()}; endfunction
    // FORMAL argument
    function void ok_arg(string a); sres = {"[", a, "]"};                    endfunction
    function void bd_arg(string a); T t; sres = {"[", a, "]", t.gt()};       endfunction
    // PACKAGE parameter
    function void ok_pkp(); sres = {"[", PKGP160, "]"};                      endfunction
    function void bd_pkp(); T t; sres = {"[", PKGP160, "]", t.gt()};         endfunction
    // DOTTED CALL on a bindable handle
    function void ok_dc();  sres = {"[", bh.gname(), "]"};                   endfunction
    function void bd_dc();  T t; sres = {"[", bh.gname(), "]", t.gt()};      endfunction
    // BARE call on `this`
    function void ok_bc();  sres = {"[", gname(), "]"};                      endfunction
    function void bd_bc();  T t; sres = {"[", gname(), "]", t.gt()};         endfunction
    // TERNARY operand
    function void ok_tn();  sres = {"[", (prop=="")?"a":"b", "]"};           endfunction
    function void bd_tn();  T t; sres = {"[", (prop=="")?"a":"b", "]", t.gt()}; endfunction
    // NESTED concatenation operand
    function void ok_nc();  sres = {"[", {"x","y"}, "]"};                    endfunction
    function void bd_nc();  T t; sres = {"[", {"x","y"}, "]", t.gt()};       endfunction
    // (an ENUM member's `.name()` operand is deliberately NOT here: SURELOG
    //  itself reports `Unresolved hierarchical reference "EB0.name"` in the
    //  ELAB view, so a golden built from it is not a golden this grid can
    //  score.)
    // DOTTED NAME (a plain member select on a bindable handle)
    function void ok_dn();  sres = {"[", bh.gname(), "]"};                   endfunction
    function void bd_dn();  T t; sres = {"[", t.fld, "]", t.gt()};           endfunction
  endclass
endpackage

module topb160;
  initial $display("hi");
endmodule
