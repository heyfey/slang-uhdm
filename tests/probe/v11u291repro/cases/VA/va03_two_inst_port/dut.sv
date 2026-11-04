// § anonAggMemberChainName291
typedef struct packed { struct packed { logic a; logic b; } [1:0] m; } t_t;
module child (input t_t i, output logic o);
  assign o = i.m[0].b;
endmodule
module dut (input t_t a, output logic [1:0] o);
  child u1 (.i(a), .o(o[0]));
  child u2 (.i(a), .o(o[1]));
endmodule
