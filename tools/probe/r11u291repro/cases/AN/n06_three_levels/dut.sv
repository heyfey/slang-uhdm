// § anonAggMemberChainName291
typedef struct packed {
  struct packed { struct packed { logic a; } [1:0] q; logic b; } [1:0] m;
} t_t;
module dut(input logic [5:0] i, output logic [5:0] o);
  t_t x;
  assign x = i;
  assign o = x;
endmodule
