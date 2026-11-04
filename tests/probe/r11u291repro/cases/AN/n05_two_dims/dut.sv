// § anonAggMemberChainName291
typedef struct packed {
  struct packed { logic a; logic b; } [1:0][2:0] m;
} t_t;
module dut(input logic [11:0] i, output logic [11:0] o);
  t_t x;
  assign x = i;
  assign o = x;
endmodule
