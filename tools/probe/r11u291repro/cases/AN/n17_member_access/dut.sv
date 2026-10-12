// § anonAggMemberChainName291
typedef struct packed { struct packed { logic a; logic b; } [1:0] m; } t_t;
module dut(input logic [3:0] i, output logic o);
  t_t x;
  assign x = i;
  assign o = x.m[1].b;
endmodule
