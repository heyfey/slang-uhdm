// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic [1:0] a; logic b; } in_t;
typedef struct packed { in_t m; logic v; } s_t;
module dut(input s_t [3:0] sd, output logic [1:0] o);
  localparam D = 2;
  assign o = sd[D*2-1].m.a;
endmodule
