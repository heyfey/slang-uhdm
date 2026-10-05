// § methArgCastTsChainName246
package p;
  typedef enum bit [1:0] {I0, I1, I2} sev_e;
  class arr_c;
    bit m[sev_e];
  endclass
  class h;
    arr_c ov;
    function void proc(int severity);
      if (this.ov.m.exists(sev_e'(severity))) begin end
      void'(this.ov.m.exists(sev_e'(severity)));
    endfunction
  endclass
endpackage
module top;
endmodule
