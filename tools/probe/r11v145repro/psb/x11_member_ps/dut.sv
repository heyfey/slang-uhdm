// § psBoundBareRefByBase145
typedef struct packed { logic [15:0] f; logic v; } s_t;
module dut(input s_t s, output logic [4:0] o);
  localparam int W = 8;
  localparam int L = 4;
  assign o = s.f[W:L];
endmodule
