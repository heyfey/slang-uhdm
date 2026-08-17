// vbuvm9 w3 — the SCOPE fence: classes and typedefs NOT homed in a package.
// $unit-level typedef, $unit-level class, class inside a MODULE, class inside
// an INTERFACE, class nested in a class, and a module-scope typedef.
typedef struct { int a; } u1_s;      // $unit-scope typedef, oob-class local
typedef struct { int a; } u2_s;      // $unit-scope typedef, module fn local

class ucl;                            // $unit-scope class
  typedef struct { int a; } uc_s;     // CLASS scope, home = $unit
  typedef int uc_i;
  extern function void f(int k);
  extern function void g();
  extern function uc_i h();
  extern function void j(uc_s v);
endclass
function void ucl::f(int k); if (k) begin uc_s v; v.a = 1; end endfunction
function void ucl::g(); uc_s v; v.a = 1; endfunction
function ucl::uc_i ucl::h(); uc_i r; r = 0; return r; endfunction
function void ucl::j(uc_s v); endfunction

class uref;                           // $unit class referencing a $unit typedef
  extern function void f(int k);
endclass
function void uref::f(int k); if (k) begin u1_s v; v.a = 1; end endfunction

module w3m;
  typedef struct { int a; } m1_s;     // MODULE-scope typedef
  class mcl;                          // class inside a MODULE
    typedef struct { int a; } mc_s;
    typedef int mc_i;
    extern function void f(int k);
    extern function mc_i h();
    extern function void j(mc_s v);
  endclass
  function void mcl::f(int k); if (k) begin mc_s v; v.a = 1; end endfunction
  function mcl::mc_i mcl::h(); mc_i r; r = 0; return r; endfunction
  function void mcl::j(mc_s v); endfunction
  function void mf(int k); if (k) begin m1_s v; v.a = 1; end endfunction
  function void uf(int k); if (k) begin u2_s v; v.a = 1; end endfunction
  initial begin mf(1); uf(1); end
endmodule

interface w3i;
  typedef struct { int a; } i1_s;
  class icl;
    typedef struct { int a; } ic_s;
    extern function void f(int k);
  endclass
  function void icl::f(int k); if (k) begin ic_s v; v.a = 1; end endfunction
  function void ifn(int k); if (k) begin i1_s v; v.a = 1; end endfunction
endinterface

package w3p;
  class outerc;
    class innerc;                      // class NESTED in a class
      typedef struct { int a; } in_s;
      function void f(int k); if (k) begin in_s v; v.a = 1; end endfunction
    endclass
    typedef struct { int a; } out_s;
    extern function void f(int k);
  endclass
  function void outerc::f(int k); if (k) begin out_s v; v.a = 1; end endfunction
endpackage
