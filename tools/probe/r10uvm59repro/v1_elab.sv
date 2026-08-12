// r10uvm59 v1_elab.sv — AXIS: DEF view vs ELAB view, and SPECIALIZATION.
//
// The corpus class is instantiated widely, so if the law were view-scoped or
// specialization-scoped a fix keyed on the default specialization alone would be
// wrong.  Here the generic class is specialised from a MODULE, so an elaborated
// view exists, and the same `T::get()` is written in BOTH a specialization whose
// binding HAS the method (slang BINDS -> § staticScopedCall12 owns it) and the
// DEFAULT specialization that nothing instantiates (slang: Invalid -> the new
// law owns it).
//
// MEASURED AND RECORDED, NOT HIDDEN: a specialization with a NON-CLASS binding
// (`w59#(int)`) is a slang HARD ERROR — "unknown class or package 'T'" — and
// rejects the WHOLE design, so that cell is UNMEASURABLE, not equal.  It is also
// why the corpus population is exactly the DEFAULT specialization of a generic
// class: an explicit non-class specialization would never have built at all.
package p59v1;
  class hasget59;
    static function hasget59 get();
      return null;
    endfunction
  endclass

  // DEFAULT specialization only — nothing instantiates this one.
  class wdef59 #(type T = int);
    static bit m_flag;
    static function void f();
      T a = T::get();
      m_flag = 1;
    endfunction
  endclass

  // Specialised below with a binding that HAS the method.
  class wspec59 #(type T = hasget59);
    static bit m_flag;
    static function void f();
      T a = T::get();
      m_flag = 1;
    endfunction
  endclass
endpackage

module v1_elab;
  import p59v1::*;
  typedef wspec59#(hasget59) wh_t;
  wh_t wh;
  initial begin
    wh_t::f();
  end
endmodule
