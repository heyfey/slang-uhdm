// § tpTypedVarInitNameSpan275 — CONTROL: a var declaration keeps the stretch
module dut #(parameter type T = logic [3:0]) (output logic [3:0] o);
  var T x = 4'h5;
  assign o = x;
endmodule
