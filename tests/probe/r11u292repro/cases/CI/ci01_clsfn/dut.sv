// § clsScopedChainIdxDirect292
package p;
  class h; int hval; endclass
  class b;
    static h stat = new();
    static int sint = 2;
  endclass
  class r;
    int arr [0:3];
    int k;
    function void f1(); arr[k] = 1; endfunction
    function void f2(); arr[b::sint] = 2; endfunction
    function void f3(); arr[b::stat.hval] = 3; endfunction
    function void f4(); arr[b::stat.hval + 1] = 4; endfunction
    function void f5(int j); arr[j] = arr[b::stat.hval]; endfunction
  endclass
endpackage
module top; p::r o = new(); endmodule
