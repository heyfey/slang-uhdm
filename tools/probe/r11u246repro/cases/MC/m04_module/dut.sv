// § methArgCastTsChainName246
typedef enum bit [1:0] {I0, I1, I2} sev_e;
class pool;
  int m[sev_e];
  function int exists(sev_e key); return m.exists(key); endfunction
endclass
module top;
  pool p;
  int s;
  initial begin
    p = new;
    if (p.exists(sev_e'(s))) $display("y");
  end
endmodule
