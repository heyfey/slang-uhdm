package pk1;
  typedef class fwd_c;

  class base_c;
    static base_c m_inst;
    int x;
    static function base_c get();
      if (m_inst == null) m_inst = new();
      return m_inst;
    endfunction
  endclass

  class deriv_c extends base_c;
    int y;
  endclass

  // ---- the shapes, all package scope, all class-typed ----
  deriv_c v_new = new();               // A: new() initializer
  base_c  v_ref = v_new;               // B: plain reference initializer
  base_c  v_none;                      // C: no initializer
  const base_c v_call = base_c::get(); // D: const + static-func-call init
  base_c  v_call2 = base_c::get();     // E: non-const + static-func-call init
  fwd_c   v_fwd;                       // F: forward-declared type, no init
  fwd_c   v_fwdnew = new();            // G: forward-declared type + new()

  // ---- non-class controls ----
  int   i_none;
  int   i_init = 5;
  logic l_none;
  string s_init = "a";

  class fwd_c;
    int z;
  endclass
endpackage

module top;
  initial begin
    if (pk1::v_none == null) $display("x");
  end
endmodule
