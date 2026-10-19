// § ifaceClassNotListed408
interface class I;
  pure virtual function int f();
endclass
class C implements I;
  virtual function int f(); return 1; endfunction
  function void g(I other); endfunction
endclass
module test;
  C h;
  initial h = new;
endmodule
