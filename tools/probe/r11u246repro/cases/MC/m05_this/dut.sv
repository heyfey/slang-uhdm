// § methArgCastTsChainName246
package p;
  typedef enum bit [1:0] {I0, I1, I2} sev_e;
  class pool;
    int m[sev_e];
    function int exists(sev_e key); return m.exists(key); endfunction
  endclass
  class h;
    pool q;
    function void proc(int s);
      if (this.q.exists(sev_e'(s))) begin end
      if (q.exists(sev_e'(this.q.m.size()))) begin end
    endfunction
  endclass
endpackage
module top;
endmodule
