// § anonAggMemberChainName291
typedef struct packed { enum logic [1:0] {A, B} e; logic c; } s_t;
module dut(output logic [2:0] o);
  s_t x;
  assign x = '0;
  assign o = x;
endmodule
