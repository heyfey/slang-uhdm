// § macroTokenFileFollowsLine125
`define W 8
`define MASK 8'h0f
module top(input [`W-1:0] a, output [`W-1:0] o);
  assign o = a & `MASK;
endmodule
