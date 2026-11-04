// § anonAggMemberChainName291
class C;
  typedef struct packed { struct packed { logic a; } [1:0] m; } t_t;
  t_t v;
endclass
module dut; C c; initial c = new; endmodule
