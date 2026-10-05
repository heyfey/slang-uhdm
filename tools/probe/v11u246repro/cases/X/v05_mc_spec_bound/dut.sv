// § methArgCastTsChainName246
package p;
  typedef enum bit [1:0] {I0, I1, I2} sev_e;
  class pc #(int W = 4);
    bit [W-1:0] v;
  endclass
  class arr_c;
    bit m[sev_e];
  endclass
  class h;
    arr_c ov[string];
    bit [$bits(pc#(3)::W)-1:0] w;
    extern function bit proc(int severity, string id);
  endclass
  function bit h::proc(int severity, string id);
    return ov[id].m.exists(sev_e'(severity + w));
  endfunction
endpackage
module top;
endmodule
