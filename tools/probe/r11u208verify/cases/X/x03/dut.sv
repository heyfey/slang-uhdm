// § methodArgNestedRefChain201 § classTdRetSharesTypedefTs200 § classTdRetVarKeepsWrittenLoc202v
class C #(type T = int);
  T v;
  function int f(int k); return k; endfunction
endclass
class D;
  typedef C #(int) c_t;
  c_t cc;
  function c_t get(int k); return cc; endfunction
endclass
class S; int n; int m[4]; endclass
module x03;
  D d;
  S s;
  int a[4];
  int i, y;
  initial begin
    y = d.get(s.n + a[i]).f(s.m[i] + 1);
    y = d.cc.f(d.get(s.m[i]).v + 1);
  end
endmodule
