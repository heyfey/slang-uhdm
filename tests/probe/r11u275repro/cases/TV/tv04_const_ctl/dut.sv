// § tpTypedVarInitNameSpan275 — CONTROL: a const declaration keeps the stretch
module dut #(parameter type T = logic [3:0]) (output logic [3:0] o);
  const T x = 4'h5;
  assign o = x;
endmodule
