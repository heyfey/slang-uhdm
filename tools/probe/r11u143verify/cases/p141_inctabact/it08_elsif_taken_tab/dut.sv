// § includeInactiveTabNotText141v
// case it08: a false ifdef, then a TAKEN elsif whose branch holds a TAB-led define
`define TWO
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
