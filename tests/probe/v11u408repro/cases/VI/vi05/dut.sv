// § ifaceClassNotListed408
interface class I1;
  pure virtual function void a();
endclass
interface class I2;
  pure virtual function void b();
endclass
class B #(int W = 2);
  int x;
endclass
class C extends B#(4) implements I1, I2;
  virtual function void a(); endfunction
  virtual function void b(); endfunction
endclass
module test;
  C h;
  initial h = new;
endmodule
