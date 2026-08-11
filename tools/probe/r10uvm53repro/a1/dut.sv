// r10uvm53repro/a1 — WHERE does a `#(...)`-spelled class handle keep its
// specialization parameters, and where is it narrowed to the generic class
// NAME TOKEN?
//
// The corpus head is uvm-1.2 base/uvm_tr_stream.svh:58
//     local uvm_set_before_get_dap#(m_uvm_tr_stream_cfg) m_cfg_dap;
// a CLASS PROPERTY.  ClassParamAsParam / ClassTypeParam (both CMP_EQUAL
// canaries) only ever spell `#(...)` at MODULE and $unit scope, so the class
// PROPERTY spelling has never been measured.  Every cell below is named in a
// comment and is read on BOTH sides.
//
// LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.

package p53;

  class cfg53;
    int q;
  endclass

  class gc53 #(type T = int);
    T t;
  endclass

  // ---- the CLASS-PROPERTY cells (the corpus-head spelling) ----
  class holder53;
    // c1_prop_spec: class PROPERTY, explicit #(...)  <-- THE HEAD SPELLING
    gc53#(cfg53) c1_prop_spec;
    // c2_prop_bare: class PROPERTY, bare generic name
    gc53 c2_prop_bare;
    // c3_prop_td: class PROPERTY through a CLASS-NESTED typedef
    typedef gc53#(cfg53) td53_t;
    td53_t c3_prop_td;

    function void f53();
      // c4_local_spec: METHOD LOCAL, explicit #(...)
      gc53#(cfg53) c4_local_spec;
      c4_local_spec = null;
    endfunction
  endclass

  // c5_pkgvar_spec: PACKAGE-scope variable, explicit #(...)
  gc53#(cfg53) c5_pkgvar_spec;

  // c6_pkgtd: PACKAGE-scope typedef, explicit #(...)
  typedef gc53#(cfg53) c6_pkgtd_t;
  c6_pkgtd_t c6_pkgtd_var;

endpackage

module top53;
  import p53::*;
  // c7_modvar_spec: MODULE-scope variable, explicit #(...) — the
  // ClassParamAsParam spelling, the one that is already CMP_EQUAL.
  gc53#(cfg53) c7_modvar_spec;
  // c8_modvar_bare: MODULE-scope variable, bare generic name.
  gc53 c8_modvar_bare;
endmodule
