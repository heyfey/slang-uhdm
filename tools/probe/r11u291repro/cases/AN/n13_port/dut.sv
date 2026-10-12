// § anonAggMemberChainName291
typedef struct packed { struct packed { logic a; logic b; } [1:0] m; } t_t;
module child(input t_t i, output logic o);
  assign o = i.m[0].a;
endmodule
module dut(input logic [3:0] i, output logic o);
  child u(.i(i), .o(o));
endmodule
