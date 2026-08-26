// r10uvm152 arm C — THE HOMES.  Where the constructor lives decides whether the
// eaten first body element leaves a PACKAGE COPY behind for the reference to
// bind, or nothing at all.  LHS is always golden.
package pc1152;
  class Kc1152;
    int q1;
  endclass
  int pc1_dummy;
endpackage

package pc2152;
  import pc1152::*;

  class Kc2152;
    int q2;
  endclass

  // (1) out-of-body constructor, EMPTY parens, class in THIS package
  class A1c152;
    int za;
    extern function new();
  endclass
  function A1c152::new();
    Kc2152 a1_first;
    Kc2152 a1_second;
    a1_first  = null;
    a1_second = null;
    za = 1;
  endfunction

  // (2) out-of-body constructor, PAREN-LESS, class in ANOTHER package (wildcard)
  class A2c152;
    int zb;
    extern function new;
  endclass
  function A2c152::new;
    Kc1152 a2_first;
    Kc1152 a2_second;
    a2_first  = null;
    a2_second = null;
    zb = 2;
  endfunction

  // (3) out-of-body constructor, EMPTY parens, SCOPED class name
  class A3c152;
    int zc;
    extern function new();
  endclass
  function A3c152::new();
    pc1152::Kc1152 a3_first;
    pc1152::Kc1152 a3_second;
    a3_first  = null;
    a3_second = null;
    zc = 3;
  endfunction

  // (4) out-of-body constructor WITH formals — the control: nothing is eaten
  class A4c152;
    int zd;
    extern function new(int k);
  endclass
  function A4c152::new(int k);
    Kc2152 a4_first;
    Kc2152 a4_second;
    a4_first  = null;
    a4_second = null;
    zd = k;
  endfunction

  // (5) IN-BODY constructor, empty parens — no package copy exists
  class A5c152;
    int ze;
    function new();
      Kc2152 a5_first;
      Kc2152 a5_second;
      a5_first  = null;
      a5_second = null;
      ze = 5;
    endfunction
  endclass

  // (6) an ordinary out-of-body METHOD, paren-less and paren'd — controls
  class A6c152;
    int zf;
    extern function void m6bare;
    extern function void m6paren();
  endclass
  function void A6c152::m6bare;
    Kc2152 a6_bare_first;
    Kc2152 a6_bare_second;
    a6_bare_first  = null;
    a6_bare_second = null;
    zf = 6;
  endfunction
  function void A6c152::m6paren();
    Kc2152 a6_par_first;
    Kc2152 a6_par_second;
    a6_par_first  = null;
    a6_par_second = null;
    zf = 7;
  endfunction

  // (7) a package FREE function — control
  function void pf7c152();
    Kc2152 a7_first;
    Kc2152 a7_second;
    a7_first  = null;
    a7_second = null;
  endfunction

  // (8) an out-of-body constructor whose eaten element is a STATEMENT
  class A8c152;
    int zg;
    extern function new();
  endclass
  function A8c152::new();
    zg = 8;
    begin
      Kc2152 a8_nested;
      a8_nested = null;
    end
  endfunction

endpackage

// (9) a $unit class with an out-of-body constructor
class U9c152;
  int zh;
  extern function new();
endclass
class KU9c152;
  int qu;
endclass
function U9c152::new();
  KU9c152 u9_first;
  KU9c152 u9_second;
  u9_first  = null;
  u9_second = null;
  zh = 9;
endfunction

module mc152;
  import pc2152::*;

  // (10) a MODULE class with an out-of-body constructor
  class KM10c152;
    int qm;
  endclass
  class M10c152;
    int zi;
    extern function new();
  endclass
  function M10c152::new();
    KM10c152 m10_first;
    KM10c152 m10_second;
    m10_first  = null;
    m10_second = null;
    zi = 10;
  endfunction

  // (11) a MODULE class with an IN-BODY constructor
  class M11c152;
    int zj;
    function new();
      KM10c152 m11_first;
      KM10c152 m11_second;
      m11_first  = null;
      m11_second = null;
      zj = 11;
    endfunction
  endclass

  initial begin
    A1c152 a1; A2c152 a2; A3c152 a3; A4c152 a4; A5c152 a5; A6c152 a6;
    A8c152 a8; U9c152 u9; M10c152 m10; M11c152 m11;
    a1 = new(); a2 = new(); a3 = new(); a4 = new(4); a5 = new(); a6 = new();
    a8 = new(); u9 = new(); m10 = new(); m11 = new();
    pf7c152();
  end
endmodule
