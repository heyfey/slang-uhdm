// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input s_t [1:0] sd, output logic [1:0] o);
  localparam D = 2;
  assign o = sd[D-1].r[2:1];
endmodule
