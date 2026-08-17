// v83 arm 18 — out-of-body CONSTRUCTOR and an out-of-body method of a VIRTUAL
// class, both declaring Owner::td.
package pa18;
  class zelem18; int q; endclass
  typedef zelem18 pkg_c_t;   // the COMPETING claim (container scope beats class scope) — makes the class typedef DEGRADE
  class zbase18;
    typedef zelem18 c_t;
  endclass
  virtual class avirt18 extends zbase18;
    extern function void f_oob();
    pure virtual function void p();
  endclass
  function void avirt18::f_oob();
    zbase18::c_t v_scoped;
  endfunction
  class actor18 extends zbase18;
    extern function new();
    virtual function void go();
      zbase18::c_t g_scoped;
    endfunction
  endclass
  function actor18::new();
    zbase18::c_t n_scoped;
    super.new();
  endfunction
endpackage
module top18;
  initial begin
    pa18::actor18 u = new();
    u.go();
  end
endmodule
