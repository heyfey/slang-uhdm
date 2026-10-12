// § clsScopedChainIdxDirect292
package p;
  class h; int hval; endclass
  class b; static h stat = new(); endclass
endpackage
interface ifc;
  int arr [0:3];
  function automatic void f(); arr[p::b::stat.hval] = 1; endfunction
endinterface
module top; ifc i(); endmodule
