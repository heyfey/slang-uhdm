// v159 VERIFIER ARM C — HOMES.  The same OPERATION-operand fold reached from an
// in-body class method, an OUT-OF-BODY (extern) class method, a STATIC method, a
// method of a NESTED class, a method of a PARAMETERISED class, a package
// function, a module function, an INTERFACE's class method, and a module
// instantiated THREE times.  MEASUREMENT ONLY.
package vq159c_pkg;
  parameter int VC = 81;
endpackage

package vp159c_pkg;
  import vq159c_pkg::*;

  // C_PKGFUNC — the measured negative control of the home=cls gate
  function automatic int c_pkgfunc(int a);
    return a + VC + 1;
  endfunction

  class vc159c;
    int r;
    // C_INBODY
    function void c_inbody();
      r = VC + 1;
    endfunction
    // C_EXTERN — declared here, BODY OUT OF THE CLASS
    extern function void c_extern();
    // C_STATIC
    static function int c_static();
      return VC + 1;
    endfunction
    // C_NESTED
    class vc159c_in;
      int q;
      function void c_nested();
        q = VC + 1;
      endfunction
    endclass
  endclass

  function void vc159c::c_extern();
    r = VC + 1;
  endfunction

  class vc159cp #(int P = 91);
    int r;
    function void c_param();
      r = VC + P;
    endfunction
  endclass
endpackage

interface vi159c;
  import vq159c_pkg::*;
  int isig;
  // C_IFACEFUNC
  function automatic int c_ifacefunc(int a);
    return a + VC + 1;
  endfunction
  class vc159ci;
    int r;
    // C_IFACECLS
    function void c_ifacecls();
      r = VC + 1;
    endfunction
  endclass
endinterface

module vs159c #(parameter int W = 1) (output int o);
  import vq159c_pkg::*;
  // C_MODFUNC
  function automatic int c_modfunc(int a);
    return a + VC + 1;
  endfunction
  // C_MODCLS — a class declared inside a MODULE
  class vc159cm;
    int r;
    function void c_modcls();
      r = VC + 1;
    endfunction
  endclass
  // C_MODPROC
  always_comb o = VC + W;
  if (W > 0) begin : gen_c
    int g;
    always_comb g = VC + 1;      // C_GENPROC
  end
endmodule

module vm159c;
  import vp159c_pkg::*;
  int o0, o1, o2;
  vc159c  h;
  vc159cp #(92) hp;
  vs159c #(.W(1)) u0 (.o(o0));
  vs159c #(.W(2)) u1 (.o(o1));
  vs159c #(.W(3)) u2 (.o(o2));
  vi159c vif();
  initial begin
    h  = new();
    hp = new();
    h.c_inbody();
    h.c_extern();
    hp.c_param();
    o0 = c_pkgfunc(1);
  end
endmodule
