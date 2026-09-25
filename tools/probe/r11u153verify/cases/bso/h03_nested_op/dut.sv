// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input s_t [7:0] sd, output logic o);
  localparam D = 3;
  assign o = sd[D*2-3].v;
endmodule
