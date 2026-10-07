// § tpTypedVarInitNameSpan275 — a var keyword produced by a macro
`define VK var
module dut #(parameter type T = logic [3:0]) (output logic [3:0] o);
  `VK T x = 4'h5;
  assign o = x;
endmodule
