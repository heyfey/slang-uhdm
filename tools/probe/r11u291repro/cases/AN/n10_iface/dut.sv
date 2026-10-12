// § anonAggMemberChainName291
typedef struct packed { struct packed { logic a; logic b; } [1:0] m; } t_t;
interface ifc; t_t d; endinterface
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc u();
  assign u.d = i;
  assign o = u.d;
endmodule
