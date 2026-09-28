// § signCastSysCallLhsTs212 — verifier: a signing cast onto an implicit net (never declared)
module dut (input logic [6:0] i, output logic o);
  assign w = signed'(i[0]);
  assign o = w;
endmodule
