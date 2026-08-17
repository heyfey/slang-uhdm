// r10buvm12 arm v1_proto12 — THE SAME-CLASS CALLEE-LINK MATRIX.
// One package, one class.  Every cell is a call written INSIDE the class body
// (in-body method or a class-property initializer) whose callee is declared in
// the SAME class, varying ONLY the callee's DECLARATION FORM and its POSITION
// relative to the caller.  The question asked of every cell is exactly what
// `func_call::Compare` reads: does the call carry `vpiFunction`, and WHICH
// object does it point at -- the class's PROTOTYPE listing or the out-of-body
// DEFINITION listing?
package p1;

  virtual class c1;
    // ---- callees declared ABOVE every caller ----------------------------
    extern virtual function int ef_above();          // extern, def out-of-body
    extern function void et_above_f();               // extern, non-virtual
    extern task ek_above();                          // extern TASK
    pure virtual function int pv_above();             // pure virtual (no body)
    function int pm_above();  return 1; endfunction  // plain in-body
    task pt_above(); endtask                         // plain in-body TASK
    extern static function int es_above();           // extern STATIC

    // ---- the CALLERS, all in-body -----------------------------------------
    function int call_ef();  return ef_above();   endfunction  // -> extern proto
    function int call_pv();  return pv_above();   endfunction  // -> pure proto
    function int call_pm();  return pm_above();   endfunction  // -> plain, above
    function int call_below(); return pm_below(); endfunction  // -> plain, BELOW
    function int call_efb(); return ef_below();   endfunction  // -> extern proto BELOW
    task call_ek(); ek_above();                    endtask      // -> extern TASK
    task call_pt(); pt_above();                    endtask      // -> plain TASK
    function int call_es();  return es_above();   endfunction  // -> extern STATIC
    function void call_etv(); et_above_f();       endfunction  // -> extern void
    // the callee in EXPRESSION position and as an ARGUMENT of another call
    function int call_expr(); return ef_above() + pm_above(); endfunction
    function int call_arg();  return pm_above2(ef_above());   endfunction
    function int pm_above2(int k); return k; endfunction

    // ---- a CLASS-PROPERTY initializer calling a prototype -----------------
    // (the property is declared ABOVE the prototype on purpose: the corpus
    //  witness `uvm_reg_field::m_predefined = m_predefine_policies()` is
    //  exactly this shape, one line ABOVE its own `extern` declaration)
    static int prop_es = es_above();
    static int prop_esb = es_below();
    extern static function int es_below();

    // ---- callees declared BELOW every caller ------------------------------
    function int pm_below(); return 2; endfunction   // plain in-body, BELOW
    extern virtual function int ef_below();          // extern, BELOW
  endclass

  function int c1::ef_above(); return 3; endfunction
  function void c1::et_above_f(); endfunction
  task c1::ek_above(); endtask
  function int c1::es_above(); return 4; endfunction
  function int c1::es_below(); return 5; endfunction
  function int c1::ef_below(); return 6; endfunction

  // ---- an OUT-OF-BODY definition calling the class's own prototypes -------
  // the corpus witness (`uvm_default_factory::set_type_override_by_type` at
  // 12476 calling `m_matches_type_override`, prototyped at 11952) says golden
  // does NOT link here; these cells are the control.
  class c2;
    extern virtual function int oob_caller();
    extern virtual function int ef2();
    function int pm2(); return 7; endfunction
  endclass
  function int c2::ef2(); return 8; endfunction
  function int c2::oob_caller(); return ef2() + pm2(); endfunction
endpackage

module top;
  p1::c1 h;
  initial begin
    h = null;
  end
endmodule
