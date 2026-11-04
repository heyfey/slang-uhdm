// § tpTypedVarInitNameSpan275 — a scalar logic type parameter
module dut #(parameter type T = logic) (output logic o);
  T x = 1'b1;
  assign o = x;
endmodule
