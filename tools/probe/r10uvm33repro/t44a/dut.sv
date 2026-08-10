// t44a — the TYPE-PARAMETER DEFAULT and the CLASS-ALIAS typedef as a formal.
//
// Pass 33's ranked #1/#2, both "golden binds the package TYPEDEF LISTING
// object where we resolve THROUGH the alias":
//   (1) `uvm_tlm_if #(type T=…, type P=uvm_tlm_phase_e)::nb_transport_fw(T t,
//       ref P p, …)` — golden `enum_typespec 'uvm_pkg::uvm_tlm_phase_e'`,
//       ours an ANONYMOUS enum_typespec.  15 rows on all four UVM-4 tests.
//   (2) `typedef uvm_time uvm_tlm_time;` used directly as a formal
//       (`b_transport(T t, uvm_tlm_time delay)`) — golden
//       `class_typespec 'uvm_pkg::uvm_tlm_time'`, ours `'uvm_time'`.
//       23 rows, BuildUVMPkg.
// Every cell has its DIRECTLY-WRITTEN control beside it.

package p44;
  typedef enum int { A0, A1 }                              e44_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; }  s44_t;
  typedef logic [7:0]                                      v44_t;

  class base44; int z; endclass
  // (2) a package CLASS-ALIAS typedef
  typedef base44 alias44_t;

  // (1) a parameterised class whose type-parameter DEFAULTS are those typedefs
  class tp44 #(type PE = e44_t, type PS = s44_t, type PV = v44_t,
               type PC = base44, type PA = alias44_t, type PI = int);
    // the formal written as the PARAMETER
    virtual function void f_pe(PE p); endfunction
    virtual function void f_ps(PS p); endfunction
    virtual function void f_pv(PV p); endfunction
    virtual function void f_pc(PC p); endfunction
    virtual function void f_pa(PA p); endfunction
    virtual function void f_pi(PI p); endfunction
    // ...and the CONTROLS, written directly
    virtual function void g_pe(e44_t    p); endfunction
    virtual function void g_ps(s44_t    p); endfunction
    virtual function void g_pv(v44_t    p); endfunction
    virtual function void g_pc(base44   p); endfunction
    virtual function void g_pa(alias44_t p); endfunction
    virtual function void g_pi(int      p); endfunction
  endclass

  // (2) the class-alias typedef as a formal of a PLAIN class and a package
  // function — no type parameter anywhere.
  class use44;
    virtual function void h_alias(alias44_t d); endfunction
    virtual function void h_class(base44    d); endfunction
  endclass
  function void fn_alias(input alias44_t d); endfunction
  function void fn_class(input base44    d); endfunction

  // a SPECIALIZATION with explicit arguments, as the control for "is the
  // default special or is it every type argument?"
  typedef tp44 #(e44_t, s44_t, v44_t, base44, alias44_t, int) tp44_exp;
endpackage

module top44a;
  import p44::*;
  tp44 #() t;
  tp44_exp te;
  use44 u;
  initial begin
    t = new(); te = new(); u = new();
    fn_alias(null); fn_class(null);
  end
endmodule
