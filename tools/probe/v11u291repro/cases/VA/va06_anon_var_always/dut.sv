// § anonAggMemberChainName291
module dut (input logic clk, input logic [3:0] a, output logic o);
  struct packed { struct packed { logic a; logic b; } [1:0] m; } v;
  always_ff @(posedge clk) v <= a;
  assign o = v.m[0].a;
endmodule
