// § cloneNewArrayCallParented244
package p;
  function automatic void mk(ref int d[], input int n); d = new[n]; endfunction
  class fac; int n; function void e(); int d[]; mk(d, n); d = new[n]; endfunction endclass
endpackage
package q; import p::*; class u; function void f(); fac x; x = null; endfunction endclass endpackage
module top; import p::*; import q::*; fac z; u w; initial w = new(); endmodule
