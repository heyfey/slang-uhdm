// § clsScopedChainIdxDirect292
package p;
  class h; int hval; int ha [0:3]; function int g(); return 1; endfunction endclass
  class b;
    static h stat = new();
    static int sarr [0:3];
    static logic [7:0] sv;
  endclass
  class r;
    int arr [0:3];
    logic [7:0] v;
    function void f1(); arr[b::sarr[1]] = 1; endfunction
    function void f2(); arr[b::stat.ha[2]] = 2; endfunction
    function void f3(); arr[b::stat.g()] = 3; endfunction
    function void f4(); v[b::stat.hval] = 1'b1; endfunction
    function void f5(); v[b::stat.hval +: 2] = 2'b1; endfunction
    function void f6(); arr[b::sv[1:0]] = 6; endfunction
    function void f7(); arr[-b::stat.hval] = 7; endfunction
    function void f8(); arr[(b::stat.hval)] = 8; endfunction
  endclass
endpackage
module top; p::r o = new(); endmodule
