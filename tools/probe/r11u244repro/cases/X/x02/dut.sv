// § hpSelIdxPathTrailByChain244
package p;
  class item; int addr; int k; endclass
  class s_t; bit addr[int]; int v[4]; endclass
  virtual class pred #(int W = 4);
    s_t pi;
    function void write(item rw);
      bit [W-1:0] z;
      this.pi.addr[rw.addr] = 1;
      pi.v[rw.k] = W;
      z = pi.v[rw.k];
    endfunction
    extern function void w2(item rw);
    pure virtual function void w3(item rw);
  endclass
  function void pred::w2(item rw);
    pi.addr[rw.addr] = 0;
  endfunction
endpackage
module top;
  typedef p::pred #(8) pt;
endmodule
