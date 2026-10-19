// § ifaceClassNotListed408
package pk;
  interface class ic;
    pure virtual function void hello();
  endclass
  class c implements ic;
    virtual function void hello(); endfunction
  endclass
endpackage
module test;
  pk::c h;
  initial h = new;
endmodule
