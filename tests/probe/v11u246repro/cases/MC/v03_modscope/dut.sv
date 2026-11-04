// § methArgCastTsChainName246
module top;
  typedef enum bit [1:0] {I0, I1, I2} sev_e;
  class arr_c;
    bit m[sev_e];
  endclass
  class h;
    arr_c ov[string];
    function bit proc(int severity, string id);
      return ov[id].m.exists(sev_e'(severity));
    endfunction
  endclass
  typedef struct { int q[$]; } s_t;
  s_t s;
  int x;
  initial s.q.push_back(int'(x));
endmodule
