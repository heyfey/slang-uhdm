// r10sd10 grid cell g6 — the OUT-OF-BODY axis.
// `CompileDesign::compile` runs its passes in this order: packages (strict
// order) -> FILE CONTENTS -> modules -> programs -> CLASSES.  An `extern`
// method's BODY is written at file scope, so it is compiled in the FileContent
// pass — BEFORE any class has been compiled at all.  A class's own typedef is
// therefore NOT available inside its own out-of-body method, while it is
// available inside its inline one.
//
// Both spellings of the type, in both body forms, so the cell scores the two
// axes independently.
package px;

  class aholder;
    typedef struct { int a; } arec_t;
  endclass

  class ccls;
    typedef struct { int a; } orec_t;      // the class's OWN typedef

    // INLINE bodies
    function void f_inline_bare();
      orec_t v_inline_bare;
      v_inline_bare.a = 1;
    endfunction
    function void f_inline_scoped();
      ccls::orec_t v_inline_scoped;
      v_inline_scoped.a = 1;
    endfunction
    function void f_inline_sibling();
      aholder::arec_t v_inline_sibling;    // sibling sorts BEFORE ccls
      v_inline_sibling.a = 1;
    endfunction

    // OUT-OF-BODY bodies
    extern function void f_ext_bare();
    extern function void f_ext_scoped();
    extern function void f_ext_sibling();
  endclass

  function void ccls::f_ext_bare();
    orec_t v_ext_bare;
    v_ext_bare.a = 1;
  endfunction

  function void ccls::f_ext_scoped();
    ccls::orec_t v_ext_scoped;
    v_ext_scoped.a = 1;
  endfunction

  function void ccls::f_ext_sibling();
    aholder::arec_t v_ext_sibling;
    v_ext_sibling.a = 1;
  endfunction

endpackage

module top;
  px::ccls c;
  initial c = new();
endmodule
