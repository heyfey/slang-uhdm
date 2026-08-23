// r10v105 arm b6 — the SHADOWING edges the predicate reads through `body.find`.
// MEASUREMENT ONLY.
package pv_b6;
  class dv_b6; int vx; endclass

  // a VIRTUAL class with an out-of-body method
  virtual class vc_b6 #(type VT = dv_b6);
    extern function void vm();
    pure virtual function void pv();
  endclass
  function void vc_b6::vm();
    VT vo_v;
  endfunction
  class cc_b6 extends vc_b6#(dv_b6);
    virtual function void pv(); endfunction
  endclass

  // a body-local TYPEDEF that SHADOWS the class's type parameter name
  class sh_b6 #(type SHT = dv_b6);
    extern function void sm();
    extern function void sm2();
  endclass
  function void sh_b6::sm();
    typedef int SHT;                 // shadows the class parameter INSIDE the body
    SHT sh_l;                        // -> what does golden do?
  endfunction
  function void sh_b6::sm2();
    SHT sh_l2;                       // no shadow here: the plain law
  endfunction

  // three type parameters at once, in a TASK, with a foreach
  class t3_b6 #(type A = dv_b6, type B = dv_b6, type C = int);
    extern task t3();
  endclass
  task t3_b6::t3();
    A a_l; B b_l; C c_l;
    int arr[3];
    foreach (arr[i]) c_l = i;
  endtask
endpackage

module topb6;
  import pv_b6::*;
  cc_b6 h_c; sh_b6 h_s; t3_b6 h_t;
  initial begin h_c = new(); h_s = new(); h_t = new(); end
endmodule
