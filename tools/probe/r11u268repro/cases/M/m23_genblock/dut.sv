// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module top #(parameter int N = 2);
  int a, b;
  for (genvar i = 0; i < N; i++) begin : g
    initial $display("%s %0d", `VS, a + b + i);
  end
  if (N > 1) begin : c
    localparam string q = `VS; initial $display("%s %0d", q, a);
  end
endmodule
