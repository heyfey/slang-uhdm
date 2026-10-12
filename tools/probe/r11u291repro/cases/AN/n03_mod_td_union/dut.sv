// § anonAggMemberChainName291
module dut(input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { union packed { logic [1:0] a; logic [1:0] b; } [1:0] m; } t_t;
  t_t x;
  assign x = i;
  assign o = x;
endmodule
