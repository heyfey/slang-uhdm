// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input logic p, output s_t o);
  localparam D = 2;
  s_t [D-1:0] sd;
  assign sd[D-1].v = p;
  assign o = sd[0];
endmodule
