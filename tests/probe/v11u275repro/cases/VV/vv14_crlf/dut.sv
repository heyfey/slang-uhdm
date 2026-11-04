// § tpTypedVarInitNameSpan275 — a CRLF file
module dut #(parameter type T = logic [3:0]) (output logic [3:0] o);
  T x = 4'h5;
  assign o = x;
endmodule
