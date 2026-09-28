// § methodArgOpRefChainName198
class C; int q[$]; function int f(int k, int j = 0); return k + j; endfunction
  task t(int k); endtask endclass
class B; function int m(int k); return k; endfunction endclass
class D extends B;
  C c; C arr[4]; string s; string args[$];
  function int g(int n, int i);
    int x;
    s = s.substr(i, args[i].len() - 1);
    return x;
  endfunction
endclass
module top; endmodule
