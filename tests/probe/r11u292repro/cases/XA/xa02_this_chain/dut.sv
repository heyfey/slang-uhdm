// § clsScopedChainIdxDirect292
package p;
  class h; int hval; endclass
  class b; static h stat = new(); endclass
  class r;
    int arr [0:3];
    function void f1(); this.arr[b::stat.hval] = 1; endfunction
    function int f2(); return this.arr[b::stat.hval]; endfunction
  endclass
endpackage
module top; p::r o = new(); endmodule
