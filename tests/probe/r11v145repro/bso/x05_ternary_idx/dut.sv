// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input s_t [3:0] sd, input logic c, output logic o);
  assign o = sd[c ? 1 : 2].v;
endmodule
