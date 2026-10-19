// § ifaceClassNotListed408
class C #(type T = int);
  T x;
endclass
interface class I;
  pure virtual function void f();
endclass
module test;
  C #(I) h;
  initial h = new;
endmodule
