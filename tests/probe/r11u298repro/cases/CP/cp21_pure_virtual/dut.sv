// § castClsTpOwnDefaultObj298
// a pure virtual prototype above an implementation casting to the type parameter
package p;
  virtual class base #(type U = logic [7:0]);
    pure virtual function int f();
  endclass
  class der #(type U = logic [5:0]) extends base #(U);
    virtual function int f(); return U'(3); endfunction
  endclass
endpackage
module top; endmodule
