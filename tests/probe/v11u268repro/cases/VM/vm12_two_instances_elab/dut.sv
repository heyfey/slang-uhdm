// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module leaf #(parameter int K = 1) (output string o);
  assign o = $sformatf("%s %0d", `VS, K + 1);
endmodule
module top(output string o1, o2); leaf #(1) u1(.o(o1)); leaf #(2) u2(.o(o2)); endmodule
