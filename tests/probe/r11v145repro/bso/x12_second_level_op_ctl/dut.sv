// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic [3:0] v; logic [3:0] r; } s_t;
module dut(input s_t [3:0] sd, input logic [1:0] i, output logic o);
  assign o = sd[1].v[i+1];
endmodule
