// § clsScopedChainIdxDirect292
package p;
  class h; int hval; endclass
  class b;
    static h stat = new();
    static int sint = 2;
  endclass
endpackage
module top;
  int arr [0:3];
  function automatic void f3(); arr[p::b::stat.hval] = 3; endfunction
  initial f3();
  always_comb arr[p::b::sint] = 1;
endmodule
