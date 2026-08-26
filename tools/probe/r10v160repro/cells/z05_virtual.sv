// r10v160 cell z05 — the rejected concatenation in a VIRTUAL method of a
// generic class, and in one the class INHERITS from a generic base.
package pv160;
  virtual class bv160 #(type T=int);
    string s;
    virtual function void m(); T t; s = {"[", t.gt(), "]"}; endfunction
  endclass
  class dv160 #(type U=int) extends bv160#(U);
    function void n(); U u; s = {"<", u.g2(), ">"}; endfunction
  endclass
endpackage
module topv160;
  initial $display("hi");
endmodule
