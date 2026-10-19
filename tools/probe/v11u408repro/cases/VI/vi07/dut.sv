// § ifaceClassNotListed408
interface class I;
  pure virtual function void f();
endclass
class C implements I;
  virtual function void f(); endfunction
endclass
module test;
  C h;
  I q[2];
  initial begin h = new; q[0] = h; end
endmodule
