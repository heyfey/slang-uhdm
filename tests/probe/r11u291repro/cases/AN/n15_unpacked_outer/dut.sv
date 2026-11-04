// § anonAggMemberChainName291
typedef struct { struct packed { logic a; logic b; } [1:0] m; int k; } t_t;
module dut(output logic o);
  t_t x;
  initial x.k = 1;
  assign o = x.m[0].a;
endmodule
