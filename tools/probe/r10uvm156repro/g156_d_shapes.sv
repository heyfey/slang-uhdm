// r10uvm156 — RETURN SHAPES.  Every way a class-handle return can be written,
// against a SAME-home class and a FAR-package class, so the law's two answers
// are exercised on each shape.  MEASUREMENT ONLY; golden = Surelog.

package fd156;
  class dfar156;
  endclass
  class dfarp156 #(type T = int);
  endclass
  virtual class dabs156;
    pure virtual function dfar156 pv_far();
  endclass
endpackage

package hd156;
  import fd156::*;
  class sibd156;
  endclass
  class base156;
    function sibd156 b_same(); return null; endfunction
    function dfar156 b_far();  return null; endfunction
  endclass
  class shapes156 extends base156;
    typedef shapes156 this_type156;                                  // self typedef
    static  function sibd156 s_same();  return null; endfunction     // STATIC
    static  function dfar156 s_far();   return null; endfunction
    virtual function sibd156 v_same();  return null; endfunction     // VIRTUAL
    virtual function dfar156 v_far();   return null; endfunction
    protected function sibd156 pr_same(); return null; endfunction   // PROTECTED
    local   function dfar156 lo_far();  return null; endfunction     // LOCAL
    function base156  r_base();  return null; endfunction            // the BASE class
    function this_type156 r_this(); return null; endfunction         // via a typedef
    function dfarp156#(int) r_par(); return null; endfunction        // specialization
    extern function sibd156 e_same();                                // EXTERN, same
    extern function dfar156 e_far();                                 // EXTERN, far
    function automatic sibd156 a_same(); return null; endfunction    // automatic
    function automatic dfar156 a_far();  return null; endfunction
  endclass
  function sibd156 shapes156::e_same(); return null; endfunction
  function dfar156 shapes156::e_far();  return null; endfunction
  class conc156 extends dabs156;
    virtual function dfar156 pv_far(); return null; endfunction
  endclass
endpackage
