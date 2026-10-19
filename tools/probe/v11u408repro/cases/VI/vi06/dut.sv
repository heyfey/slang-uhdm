// § ifaceClassNotListed408
package pk;
  interface class I;
    pure virtual function void f();
  endclass
endpackage
import pk::*;
class C implements I;
  virtual function void f(); endfunction
endclass
module test;
  C h;
  initial h = new;
endmodule
