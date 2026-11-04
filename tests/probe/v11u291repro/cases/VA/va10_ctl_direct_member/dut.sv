// § anonAggMemberChainName291
typedef struct packed { struct packed { logic a; logic b; } m; logic c; } t_t;
module dut (input t_t a, output logic o);
  assign o = a.m.a ^ a.c;
endmodule
