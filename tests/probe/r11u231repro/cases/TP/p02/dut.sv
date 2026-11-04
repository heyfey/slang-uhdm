// § tfArgTypeParamDefaultWriter231 — the second type parameter defaults to the enum (uvm_tlm_if's P)
package p;
  typedef enum {BEGIN_REQ, END_REQ} ph_e;
  class ifc #(type T=int, type P=ph_e);
    virtual function int nb(T t, ref P p);
      return 0;
    endfunction
  endclass
endpackage
module top;
endmodule
