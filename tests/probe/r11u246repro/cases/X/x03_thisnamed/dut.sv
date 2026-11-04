// § methArgCastTsChainName246
package p;
  typedef enum bit [1:0] {I0, I1, I2} sev_e;
  class pool;
    int m[sev_e];
    function int exists(sev_e key, int dflt = 0); return m.exists(key); endfunction
  endclass
  virtual class base;
    pure virtual function int vf(sev_e s);
    extern function int ef(sev_e s);
  endclass
  function int base::ef(sev_e s); return int'(s); endfunction
  class h extends base;
    pool q;
    function int vf(sev_e s); return this.q.exists(.key(sev_e'(s))); endfunction
    function void proc(int s);
      if (this.q.exists(sev_e'(s), )) begin end
      if (q.exists(.dflt(1), .key(sev_e'(s)))) begin end
    endfunction
  endclass
endpackage
module top;
endmodule
