// § ifaceClassNotListed408
package pk;
  interface class I;
    pure virtual function int f();
  endclass
  class B implements I;
    virtual function int f(); return 1; endfunction
  endclass
  class D extends B;
    int z;
  endclass
endpackage
module test;
  pk::D h;
  initial h = new;
endmodule
