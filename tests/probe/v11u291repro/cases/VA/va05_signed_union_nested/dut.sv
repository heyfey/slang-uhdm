// § anonAggMemberChainName291
typedef struct packed signed {
  union packed { logic [1:0] x; struct packed { logic p; logic q; } y; } [1:0] u;
  logic z;
} s_t;
module dut (input s_t a, output logic o);
  assign o = a.u[1].y.p ^ a.z;
endmodule
