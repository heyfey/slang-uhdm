// § ifaceClassNotListed408
program prg;
  interface class I;
    pure virtual function void f();
  endclass
  class C implements I;
    virtual function void f(); endfunction
  endclass
  C h;
  initial h = new;
endprogram
