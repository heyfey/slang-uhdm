// § hpSelIdxPathTrailByChain244
package p;
  class item; int addr; endclass
  class s_t; bit addr[int]; endclass
  class pred;
    function void write(item rw, s_t pi);
      pi.addr[rw.addr] = 1;
    endfunction
  endclass
endpackage
package q;
  import p::*;
  class u; function void f(); pred x; x = null; endfunction endclass
endpackage
module top; import p::*; import q::*; pred z; u w; initial w = new(); endmodule
