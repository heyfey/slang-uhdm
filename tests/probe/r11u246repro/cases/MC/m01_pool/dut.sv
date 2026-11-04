// § methArgCastTsChainName246
package p;
  typedef enum bit [1:0] {I0, I1, I2} sev_e;
  class pool #(type KEY = int, T = int);
    T m[KEY];
    function int exists(KEY key);
      return m.exists(key);
    endfunction
  endclass
  typedef pool#(sev_e, sev_e) ov_t;
  class h;
    ov_t ov[string];
    function void proc(string id);
      sev_e severity;
      if (ov[id].exists(sev_e'(severity))) begin end
    endfunction
  endclass
  function void pf(sev_e s);
  endfunction
  class zq;
    function void mz(sev_e severity);
    endfunction
  endclass
endpackage
module top;
endmodule
