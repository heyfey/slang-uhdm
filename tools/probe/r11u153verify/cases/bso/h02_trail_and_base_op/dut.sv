// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input s_t [3:0] sd, output logic o);
  localparam D = 4;
  localparam E = 2;
  assign o = sd[D-1].r[E-1];
endmodule
