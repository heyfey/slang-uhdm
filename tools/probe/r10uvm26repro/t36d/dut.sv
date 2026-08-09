// t36d — the vpiExpr shape of a class-scope static-call initializer at package
// scope: golden gives uvm_top (uvm_root::get, an EXTERN prototype with an
// out-of-body body) a func_call, and uvm_resources / uvm_test_done /
// uvm_cmdline_proc (in-body static getters) a ref_obj.  Both arms here.
package pk1;

  class inbody_c;
    static inbody_c m_i;
    static function inbody_c get();
      if (m_i == null) m_i = new();
      return m_i;
    endfunction
  endclass

  class extern_c;
    static extern_c m_i;
    extern static function extern_c get();
  endclass

  function extern_c extern_c::get();
    if (m_i == null) m_i = new();
    return m_i;
  endfunction

  // A: in-body getter
  const inbody_c v_inbody = inbody_c::get();
  // B: extern prototype + out-of-body body
  const extern_c v_extern = extern_c::get();
  // C: non-const arms of the same two (net-decl shape -> auto=0)
  inbody_c v_inbody_nc = inbody_c::get();
  extern_c v_extern_nc = extern_c::get();
endpackage

module top;
  initial begin
    if (pk1::v_inbody == null) $display("x");
  end
endmodule
