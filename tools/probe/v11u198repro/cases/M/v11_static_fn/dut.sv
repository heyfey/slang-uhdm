// § methodArgOpRefChainName198
class C; int q[$]; int v; function int f(int k, int j = 0); return k + j; endfunction endclass
class D;
  static C c;
  static function int g(int i);
    return c.f(i * 3);
  endfunction
endclass
module top; endmodule
