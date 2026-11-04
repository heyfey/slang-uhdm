// § anonAggMemberChainName291
package p;
  typedef struct packed { struct packed { enum logic [1:0] {A, B} e; logic c; } in; logic [1:0] b; } s_t;
endpackage
module dut(output logic [4:0] o);
  p::s_t x;
  assign x = '0;
  assign o = x;
endmodule
