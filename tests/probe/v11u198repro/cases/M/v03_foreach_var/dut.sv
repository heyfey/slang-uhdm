// § methodArgOpRefChainName198
class C; int q[$]; int v; function int f(int k, int j = 0); return k + j; endfunction
  function C h(int k); return this; endfunction
  task t(int k); endtask endclass
class D;
  C c; int arr[4];
  function int g();
    int x;
    foreach (arr[j]) x += c.f(j * 2);
    return x;
  endfunction
endclass
module top; endmodule
