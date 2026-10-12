// § clsScopedChainIdxDirect292
package p;
  class h; int hval; endclass
  class g #(type T = int); static h stat = new(); endclass
  class r;
    int arr [0:3];
    function void f1(); arr[g#(int)::stat.hval] = 1; endfunction
  endclass
endpackage
module top; p::r o = new(); endmodule
