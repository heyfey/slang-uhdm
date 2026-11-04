// § signCastSysCallLhsTs212 — verifier: a signing cast onto a signed output logic port
module dut (input logic [9:0] i, output logic signed [6:0] o);
  assign o = signed'(i[6:0]);
endmodule
