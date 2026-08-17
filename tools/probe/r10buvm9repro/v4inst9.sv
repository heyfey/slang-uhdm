// r10buvm9 v4 — the two shapes the 9 ELAB-listed offenders actually have:
// a PARAMETERIZED-CLASS specialization typedef (`typedef uvm_callback_iter#(..)
// uvm_reg_cb_iter`) and a TYPEDEF-OF-TYPEDEF (`typedef uvm_sequencer_arb_mode
// UVM_SEQ_ARB_TYPE`), each referenced the way uvm_pkg references it.
package s9;

  class pc9 #(type T = int);
    T v;
    function new(); endfunction
  endclass

  typedef enum { D0X, D0Y } d0_e;          // the base enum typedef

  typedef pc9#(int) d1_t;   // spec typedef, used as an OUT-OF-BODY nested local
  typedef pc9#(bit) d2_t;   // spec typedef, used as an out-of-body TOP local
  typedef pc9#(byte) d3_t;  // spec typedef, used as an IN-BODY local
  typedef pc9#(shortint) d4_t; // spec typedef, referenced NOWHERE (fence)
  typedef pc9#(longint) d5_t;  // spec typedef, used as a class MEMBER
  typedef pc9#(real) d6_t;     // spec typedef, out-of-body FORMAL
  typedef pc9#(time) d7_t;     // spec typedef, out-of-body RETURN

  typedef d0_e d8_t;       // typedef-of-typedef, out-of-body FORMAL
  typedef d0_e d9_t;       // typedef-of-typedef, out-of-body nested local
  typedef d0_e d10_t;      // typedef-of-typedef, referenced nowhere (fence)

  class k4;
    d5_t m_d5;
    extern function void f1(int k);
    extern function void f2();
    function void f3(); d3_t v; v = new(); endfunction
    extern function void f6(d6_t v);
    extern function d7_t f7();
    extern function void f8(d8_t v);
    extern function void f9(int k);
  endclass
  function void k4::f1(int k); if (k) begin d1_t v; v = new(); end endfunction
  function void k4::f2(); d2_t v; v = new(); endfunction
  function void k4::f6(d6_t v); endfunction
  function s9::d7_t k4::f7(); d7_t r; r = new(); return r; endfunction
  function void k4::f8(d8_t v); endfunction
  function void k4::f9(int k); if (k) begin d9_t v; v = D0X; end endfunction

endpackage
