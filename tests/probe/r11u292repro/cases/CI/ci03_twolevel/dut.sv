// § clsScopedChainIdxDirect292
package p;
  class h; int hval; endclass
  class b;
    static h stat = new();
  endclass
  class r;
    int arr [0:3][0:3];
    int m [0:3];
    function void f1(); arr[b::stat.hval][1] = 1; endfunction
    function void f2(); arr[0][b::stat.hval] = 2; endfunction
    function void f3(); m[m[b::stat.hval]] = 3; endfunction
  endclass
endpackage
module top; p::r o = new(); endmodule
