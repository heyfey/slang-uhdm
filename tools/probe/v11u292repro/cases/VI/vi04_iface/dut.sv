// § clsScopedChainIdxDirect292
package p;
  class b; int hval; static b stat = new(); endclass
  int pi[3];
endpackage
interface ifc;
  logic [7:0] a; logic z;
  function automatic logic g(); return a[p::b::stat.hval]; endfunction
  always_comb z = a[p::pi[1]];
endinterface
module top; ifc i(); endmodule
