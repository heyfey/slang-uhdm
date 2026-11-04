// § parseViewSizeExprEval228 — a header included by two modules
module a (output logic [7:0] o);
`include "w.svh"
  assign o = wh;
endmodule
module dut (output logic [7:0] o1, o2);
`include "w.svh"
  a u (.o(o2));
  assign o1 = wh;
endmodule
