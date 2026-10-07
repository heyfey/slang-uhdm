// § tpTypedVarInitNameSpan275 — an initializer spanning lines
module dut #(parameter type T = logic [7:0], parameter int P = 3) (output logic [7:0] o);
  T x = (P +
         8'h10);
  assign o = x;
endmodule
