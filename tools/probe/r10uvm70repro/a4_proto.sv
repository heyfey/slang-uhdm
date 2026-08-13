// r10uvm70 arm a4 — the FOUR return-var FACTORIES that are not the ordinary
// in-body one, so a law stated for "the return variable" is measured at every
// site that mints one instead of at the one site the head happened to use:
//   1. a PURE VIRTUAL prototype          (TaskFuncEmit ~2402)
//   2. a DPI-IMPORT prototype            (TaskFuncEmit ~2941)
//   3. drainFuncRet's per-reference body local for a MODULE function whose
//      return name is READ in its own body   (ModuleEmit ~20622)
//   4. an out-of-body `extern` body       (the ordinary site, span control)
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
package p4;
  virtual class base4;
    pure virtual function unsigned pv_u();        // line 12
    pure virtual function signed   pv_s();        // line 13
    pure virtual function          pv_imp();      // line 14  (control)
    pure virtual function int      pv_int();      // line 15  (control)
  endclass

  import "DPI-C" function unsigned dpi_u();       // line 18
  import "DPI-C" function int      dpi_int();     // line 19  (control)
endpackage

module a4;
  // drainFuncRet: the return NAME is read inside the body, so a per-reference
  // body-local return var is minted for it.
  function unsigned selfref_u;                    // line 25
    selfref_u = 1'b0;
    if (selfref_u) selfref_u = 1'b1;
  endfunction
  function signed selfref_s;                      // line 29
    selfref_s = 1'b0;
    if (selfref_s) selfref_s = 1'b1;
  endfunction
  function int selfref_i;                         // line 33  (control)
    selfref_i = 0;
    if (selfref_i) selfref_i = 1;
  endfunction

  wire w1 = selfref_u();
  wire w2 = selfref_s();
  wire w3 = selfref_i() != 0;
endmodule
