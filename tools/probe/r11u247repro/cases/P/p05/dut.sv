// § pureVirtFormalSignKwTrim247
package p;
  virtual class base;
    pure virtual function void setp(int
       unsigned prec, int /* c */ signed q);
  endclass
endpackage
package q;
  import p::*;
  class d extends base;
    virtual function void setp(int unsigned prec, int signed q); endfunction
  endclass
endpackage
module top;
  import q::*;
  d x;
endmodule
