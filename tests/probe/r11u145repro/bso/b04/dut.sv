// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input logic p, output s_t o, output logic q);
  localparam D = 2;
  s_t [D-1:0] sd;
  assign sd = '0;
  always_comb q = sd[D-1].v;
  assign o = sd[0];
endmodule
