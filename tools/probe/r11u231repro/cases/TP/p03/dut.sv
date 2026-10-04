// § tfArgTypeParamDefaultWriter231 — control: the default is package-qualified from another package (not modelled)
package p;
  typedef enum {BEGIN_REQ, END_REQ} ph_e;
endpackage
package q;
  class ifc #(type P=p::ph_e);
    virtual function int nb(ref P ph);
      return 0;
    endfunction
  endclass
endpackage
module top;
endmodule
