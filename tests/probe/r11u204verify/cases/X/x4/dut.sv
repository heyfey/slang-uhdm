// § methodArgOpRefChainName198 § formalDefaultNamedThroughFormal191: a method whose default names an earlier formal, called with an operation argument over a formal whose own default names another formal
class C; function int f(int k, int j = k + 1); return k + j; endfunction endclass
class D;
  C c;
  function int g(int n, int i = n * 2);
    int x;
    x = c.f(i + n);
    x = c.f(n - 1, i ^ n);
    return x;
  endfunction
endclass
module top; endmodule
