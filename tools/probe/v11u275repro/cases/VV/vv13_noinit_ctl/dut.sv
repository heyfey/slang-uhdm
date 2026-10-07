// § tpTypedVarInitNameSpan275 — control: no initializer
module dut #(parameter type T = logic [3:0]) (input logic [3:0] i, output logic [3:0] o);
  T x;
  assign x = i;
  assign o = x;
endmodule
