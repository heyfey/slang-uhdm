// § ifaceClassNotListed408
typedef interface class I;
class U;
  int y;
endclass
interface class I;
  pure virtual function void f();
endclass
class C implements I;
  virtual function void f(); endfunction
endclass
module test;
  C h;
  initial h = new;
endmodule
