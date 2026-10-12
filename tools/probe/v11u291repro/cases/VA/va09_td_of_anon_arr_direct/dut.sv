// § anonAggMemberChainName291
typedef struct packed { logic a; logic [1:0] b; } [2:0] t_t;
module dut (input t_t a, output logic o);
  assign o = a[2].a;
endmodule
