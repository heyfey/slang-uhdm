// (r11u191) the same argument shapes in a module function (a non-class scope)
class C; function int f(int k, int j); return k + j; endfunction endclass
module top;
  C c; C arr[4];
  function int g(int n, int i);
    return c.f(n, i + 1) + arr[i].f(n, n);
  endfunction
endmodule
