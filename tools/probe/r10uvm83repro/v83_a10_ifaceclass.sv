// v83 arm 10 — INTERFACE CLASS as the typedef Owner.
package pa10;
  class zelem10; int q; endclass
  typedef zelem10 pkg_c_t;   // the COMPETING claim (container scope beats class scope) — makes the class typedef DEGRADE
  interface class ic10;
    typedef zelem10 c_t;
    pure virtual function void go();
  endclass
  class aimp10 implements ic10;
    extern virtual function void go();
    function void f_inline();
      ic10::c_t i_iscoped;
    endfunction
  endclass
  function void aimp10::go();
    ic10::c_t o_iscoped;
  endfunction
endpackage
module top10;
  initial begin
    pa10::aimp10 u = new();
    u.go();
  end
endmodule
