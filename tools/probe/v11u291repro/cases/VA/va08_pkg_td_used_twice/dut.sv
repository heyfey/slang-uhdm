// § anonAggMemberChainName291
package pk;
  typedef struct packed { struct packed { logic a; logic b; } [1:0] m; } t_t;
endpackage
module dut (input pk::t_t a, output logic o);
  pk::t_t v;
  assign v = a;
  assign o = v.m[0].a;
endmodule
