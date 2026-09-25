// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input s_t [3:0] sd, input logic [3:0] j, output logic o);
  assign o = sd[j[1:0] + 1].v;
endmodule
