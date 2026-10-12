// § anonAggMemberChainName291
module dut (output logic o);
  struct packed { struct packed { logic a; logic b; } [1:0] m; } v = '0;
  assign o = v.m[0].a;
endmodule
