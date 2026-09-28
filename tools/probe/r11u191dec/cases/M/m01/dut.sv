// (r11u191 N0175 / N0192 / N0217 / N0220) references in the arguments of a method call on a path
class C; int q[$]; function int f(int k, int j); return k + j; endfunction endclass
class D;
  C c; C arr[4]; string s; string args[$];
  function void g(int n, int i);
    int x;
    x = c.f(n, i + 1);
    x = arr[i].f(n, n);
    s = s.substr(i, args[i].len() - 1);
    x = c.q[i + 1];
  endfunction
endclass
module top; endmodule
