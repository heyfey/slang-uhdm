// § methArgCastTsChainName246
package p;
  typedef enum bit [1:0] {I0, I1, I2} sev_e;
  class arr_c;
    bit m[sev_e];
    int q[$];
  endclass
  class h;
    arr_c ov[string];
    function void proc(int severity, string id);
      if (ov[id].m.exists(sev_e'($unsigned(severity)))) begin end
      if (ov[id].m.exists(sev_e'($signed(int'(severity))))) begin end
      ov[id].q.push_back(int'(severity) + 1);
      ov[id].q.push_back(severity > 0 ? int'(severity) : 0);
    endfunction
  endclass
endpackage
module top;
endmodule
