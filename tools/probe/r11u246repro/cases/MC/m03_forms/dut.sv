// § methArgCastTsChainName246
package p;
  typedef enum bit [1:0] {I0, I1, I2} sev_e;
  class pool #(type KEY = int);
    int m[KEY];
    function int exists(KEY key); return m.exists(key); endfunction
    function void put(KEY key, int v); m[key] = v; endfunction
  endclass
  class h;
    pool#(sev_e) ov[string];
    pool#(sev_e) one;
    function void proc(string id, int s);
      if (ov[id].exists(sev_e'(s))) begin end
      one.put(sev_e'(s + 1), 3);
      void'(one.exists(sev_e'(s) == I1 ? I2 : I0));
      ov[id].put(sev_e'(s), int'(s));
    endfunction
  endclass
endpackage
module top;
endmodule
