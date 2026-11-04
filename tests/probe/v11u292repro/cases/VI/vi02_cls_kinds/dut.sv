// § clsScopedChainIdxDirect292
package p;
  class b; int hval; int arr[4]; static b stat = new(); function int get(); return 1; endfunction endclass
  class r;
    int a[8]; logic [15:0] v; int m[4][4];
    function void f1();
      int x;
      x = a[b::stat.hval];
      x = a[b::stat.arr[2]];
      x = a[b::stat.get()];
      x = m[b::stat.hval][1];
      x = m[1][b::stat.hval];
      a[b::stat.hval] = 3;
      x = v[b::stat.hval -: 2];
      x = a[-b::stat.hval];
      x = a[(b::stat.hval)];
    endfunction
  endclass
endpackage
module top; endmodule
