// § anonAggMemberChainName291
module dut (output logic o);
  localparam struct packed { struct packed { logic a; logic b; } [1:0] m; } P = '{m: 4'b1010};
  assign o = P.m[1].a;
endmodule
