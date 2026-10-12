// § streamPartSelLazyName288 — part-selects as streaming TARGET operands in two processes
module top(input logic [7:0] i, output logic [7:0] o, p);
  always_comb {<< 2 {p[3:0], p[7:4]}} = i;
  always_comb {>> {o[7:4], o[3:0]}} = i;
endmodule
