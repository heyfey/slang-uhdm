// § signCastSysCallLhsTs212 — verifier: a signing cast onto a scalar wire
module dut (input logic [3:0] i, output logic o);
  wire w;
  assign w = unsigned'(i[1]);
  assign o = w;
endmodule
