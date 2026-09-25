// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input s_t [3:0] sd, input logic [1:0] i, output logic o);
  always_comb o = sd[i+1].v;
endmodule
