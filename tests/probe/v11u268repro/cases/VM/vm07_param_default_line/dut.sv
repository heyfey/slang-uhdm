// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module leaf #(parameter string S = `VS, parameter int K = 3 + 4) (output int o);
  assign o = K;
endmodule
module top(output int o); leaf #(.K(5)) u(.o(o)); endmodule
