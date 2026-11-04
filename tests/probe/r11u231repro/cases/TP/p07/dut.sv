// § tfArgTypeParamDefaultWriter231 — the formal is written by a macro (uvm_tlm2_imps.svh style)
`define NB_IMP(T, P, t, p) \
  virtual function int nb(T t, ref P p); \
    return 0; \
  endfunction
package p;
  typedef enum {BEGIN_REQ, END_REQ} ph_e;
  class sock #(type T=int, type P=ph_e);
    `NB_IMP(T, P, t, p)
  endclass
endpackage
module top;
endmodule
