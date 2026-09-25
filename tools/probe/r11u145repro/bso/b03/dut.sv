// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input logic p, input logic [1:0] i, output s_t o);
  s_t [3:0] sd;
  always_comb begin
    sd = '0;
    sd[i + 1].v = p;
  end
  assign o = sd[0];
endmodule
