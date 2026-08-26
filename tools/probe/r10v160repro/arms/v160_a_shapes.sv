// r10v160 arm A — OPERAND SHAPES THE LAW MUST GET RIGHT OR REFUSE.
// Variants of the five modelled shapes that the implementer's arm B does not
// write, plus shapes OUTSIDE the five (which must make the WHOLE concatenation
// abstain, i.e. stay byte-for-byte pristine).  Every `bd_*` concatenation has
// one operand slang binds bad IN SILENCE (a method call on a local whose type
// is a generic class's DEFAULT type parameter).  MEASUREMENT ONLY.
package pva160;
  parameter string PKGPA = "pp";
  class baseva160;
    function new(string name="x"); endfunction
    function string gn(string s="q"); return s; endfunction
  endclass

  class holdva160 #(type T=int, string FLD="f") extends baseva160;
    static string sa = "";
    string prop;
    baseva160 bh;
    int iv;

    // --- STRING LITERAL variants -------------------------------------
    // s1 an ESCAPED QUOTE inside the literal
    function void s1(); T t; sa = {"a\"b", t.gt()};                 endfunction
    // s2 an ESCAPED NEWLINE
    function void s2(); T t; sa = {"a\nb", t.gt()};                 endfunction
    // s3 a DOUBLED BACKSLASH
    function void s3(); T t; sa = {"a\\b", t.gt()};                 endfunction
    // s4 an EMPTY literal
    function void s4(); T t; sa = {"", t.gt()};                     endfunction
    // s5 a literal containing `::` and `.` (must not be re-parsed)
    function void s5(); T t; sa = {"p::q.r", t.gt()};               endfunction
    // s6 a literal with a TAB escape
    function void s6(); T t; sa = {"a\tb", t.gt()};                 endfunction
    // ACCEPTED twins of each literal shape (the oracle: these must be
    // byte-identical to golden on BOTH binaries, before and after)
    function void k1(); sa = {"a\"b", prop};                        endfunction
    function void k2(); sa = {"a\nb", prop};                        endfunction
    function void k3(); sa = {"a\\b", prop};                        endfunction
    function void k4(); sa = {"", prop};                            endfunction
    function void k5(); sa = {"p::q.r", prop};                      endfunction
    function void k6(); sa = {"a\tb", prop};                        endfunction

    // --- SCOPED variants ---------------------------------------------
    // s7 THREE segments
    function void s7(); T t; sa = {"[", T::inner::tn, "]", t.gt()}; endfunction
    // s8 a scoped CALL WITH ARGUMENTS
    function void s8(); T t; sa = {"[", T::mk("z"), "]", t.gt()};   endfunction
    // s9 a scoped call with a DOTTED argument
    function void s9(); T t; sa = {"[", T::mk(bh.gn), "]", t.gt()}; endfunction

    // --- DOTTED variants ---------------------------------------------
    // s10 a dotted call with a DOTTED actual
    function void s10(); T t; sa = {"[", bh.gn(t.fl), "]", t.gt()}; endfunction
    // s11 a THREE-deep dotted name — OUTSIDE the five: the whole concat
    //     must ABSTAIN (byte-for-byte pristine)
    function void s11(); T t; sa = {"[", bh.bh.prop, "]", t.gt()};  endfunction
    // s12 a dotted call on a DOTTED receiver — likewise OUTSIDE
    function void s12(); T t; sa = {"[", bh.bh.gn(), "]", t.gt()};  endfunction

    // --- SHAPES OUTSIDE THE FIVE: the concat must stay PRISTINE -------
    // s13 an INTEGER literal operand beside a bad one
    function void s13(); T t; sa = {8'd5, t.gt()};                  endfunction
    // s14 an INDEXED operand
    function void s14(); T t; sa = {"[", prop[0], "]", t.gt()};     endfunction
    // s15 a BINARY operand
    function void s15(); T t; sa = {"[", prop, "]", t.gt(), "x"};   endfunction
    // s16 a SYSTEM-call operand
    function void s16(); T t; sa = {$sformatf("%0d", iv), t.gt()};  endfunction
    // s17 a PARENTHESIZED identifier operand
    function void s17(); T t; sa = {("[" ), prop, t.gt()};          endfunction

    // --- the five, ALL AT ONCE, in one concatenation ------------------
    function void s18(); T t;
      sa = {"lit", FLD, bh.gn, bh.gn(), T::tn, t.gt()};             endfunction
  endclass
endpackage

module topva160;
  initial $display("hi");
endmodule
