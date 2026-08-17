// v83 arm 08 — SELF-QUALIFIED own typedef in an out-of-body method, plus a
// STRUCT typedef (the sharedClassTypedef / typedefTs-shared arm the resolved
// typespec site deliberately does NOT stamp).
package pa8;
  class zelem8; int q; endclass
  typedef zelem8 pkg_c_t;   // the COMPETING claim (container scope beats class scope) — makes the class typedef DEGRADE
  class abase8;
    typedef zelem8 c_t;
    typedef struct { int a; } s_t;
    extern function void f_oob();
    function void f_inline();
      abase8::c_t i_selfq;
      abase8::s_t i_selfs;
    endfunction
  endclass
  function void abase8::f_oob();
    abase8::c_t o_selfq;
    abase8::s_t o_selfs;
  endfunction
endpackage
module top8;
  initial begin
    pa8::abase8 u = new();
    u.f_oob();
  end
endmodule
