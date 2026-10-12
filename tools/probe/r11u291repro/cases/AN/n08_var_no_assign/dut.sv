// § anonAggMemberChainName291
module dut(input logic [4:0] i, output logic [4:0] o);
  struct packed { struct packed { logic a; logic b; } [1:0] m; logic c; } x;
  always_comb x = i;
  assign o = x;
endmodule
