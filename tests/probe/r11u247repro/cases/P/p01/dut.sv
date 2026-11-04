// § pureVirtFormalSignKwTrim247
package p;
  virtual class base;
    pure virtual function void setp(int unsigned prec);
    pure virtual function int unsigned getp();
  endclass
  class impl extends base;
    int unsigned m;
    virtual function void setp(int unsigned prec); m = prec; endfunction
    virtual function int unsigned getp(); return m; endfunction
  endclass
endpackage
module top;
  import p::*;
  impl x;
  initial begin x = new(); x.setp(3); end
endmodule
