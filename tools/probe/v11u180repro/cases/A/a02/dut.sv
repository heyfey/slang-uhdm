// § classTpFormalMovesTs180 (verifier: a pure virtual prototype formal in a virtual class)
package pkg;
  class base_c; endclass
  virtual class holder #(type CB=base_c);
    CB m;
    pure virtual function void f(CB x);
  endclass
  class impl extends holder;
    virtual function void f(base_c x); endfunction
  endclass
endpackage
module top();
pkg::impl c1;
endmodule
