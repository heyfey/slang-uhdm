// § clsTdArgAliasTwin414
interface class ic;
  typedef int T;
  pure virtual function void f(T a);
endclass
class C implements ic;
  virtual function void f(ic::T a);
  endfunction
endclass
module top;
  C c;
endmodule
