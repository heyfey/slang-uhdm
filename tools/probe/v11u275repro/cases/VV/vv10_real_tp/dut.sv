// § tpTypedVarInitNameSpan275 — a real type parameter with an initializer
module dut #(parameter type T = real) (output logic o);
  T x = 1.5;
  assign o = (x > 1.0);
endmodule
