// § anonAggMemberChainName291
`include "t.svh"
module dut(input logic [3:0] i, output logic [3:0] o);
  t_t x;
  assign x = i;
  assign o = x;
endmodule
