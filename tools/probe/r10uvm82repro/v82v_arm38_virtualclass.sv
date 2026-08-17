package pk38;
  parameter int P38 = 5;
endpackage
module top;
  import pk38::*;
  virtual class V38;
    pure virtual function int f();
  endclass
  class R38 extends V38;
    virtual function int f(); return P38; endfunction
  endclass
  R38 c;
endmodule
