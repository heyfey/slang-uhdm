// § anonAggMemberChainName291
typedef struct packed {
  struct packed { enum {A, B} e; logic f; } in;
  logic g;
} s_t;
module dut (input s_t a, output logic o);
  assign o = a.in.f ^ a.g;
endmodule
