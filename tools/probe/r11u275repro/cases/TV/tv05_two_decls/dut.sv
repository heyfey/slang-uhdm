// § tpTypedVarInitNameSpan275 — two declarators with initializers
module dut #(parameter type T = logic [3:0]) (output logic [3:0] o, p);
  T x = 4'h5, y = 4'ha;
  assign o = x;
  assign p = y;
endmodule
