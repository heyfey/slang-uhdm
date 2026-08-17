// v83 arm 12 — TYPEDEF CHAIN: the owner's typedef itself names a class-scoped
// typedef (the DECLINE arm of classScopedTdUnsupName11), in and out of body.
package pa12;
  class zelem12; int q; endclass
  typedef zelem12 pkg_c_t;   // the COMPETING claim (container scope beats class scope) — makes the class typedef DEGRADE
  class zother12;
    typedef zelem12 o_t;
  endclass
  class zhold12;
    typedef zother12::o_t t_td;   // target itself class-scoped
    typedef zelem12       plain_td;
  endclass
  class aderiv12 extends zhold12;
    extern function void f_oob();
    function void f_inline();
      zhold12::t_td     i_chain;
      zhold12::plain_td i_plain;
    endfunction
  endclass
  function void aderiv12::f_oob();
    zhold12::t_td     o_chain;
    zhold12::plain_td o_plain;
  endfunction
endpackage
module top12;
  initial begin
    pa12::aderiv12 u = new();
    u.f_oob();
  end
endmodule
