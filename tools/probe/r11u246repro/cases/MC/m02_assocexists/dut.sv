// § methArgCastTsChainName246
package p;
  typedef enum bit [1:0] {I0, I1, I2} sev_e;
  function void pf(sev_e s);
  endfunction
  class zq;
    function void mz(sev_e severity);
    endfunction
  endclass
  class arr_c;
    bit m[sev_e];
  endclass
  class h;
    arr_c ov[string];
    function void proc(int severity, string id);
      if (ov[id].m.exists(sev_e'(severity))) begin end
    endfunction
  endclass
endpackage
module top;
endmodule
