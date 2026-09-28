// § methodArgNestedRefChain201 § classTdRetSharesTypedefTs200 § classTdRetVarKeepsWrittenLoc202v
class C #(type T = int);
  T v;
endclass
class D;
  typedef C #(int) c_t;
  c_t cc;
  function c_t get(int k); return cc; endfunction
endclass
class S; int n; int m[4]; endclass
module x09;
  D d;
  S s;
  int a[4];
  int i;
  D::c_t h;
  initial begin
    h = d.get(s.m[i] + a[i]);
    h = d.get(s.m[a[i]] - 1);
  end
endmodule
