// § signCastSysCallLhsTs212 — verifier: a signing cast onto an int variable and onto a bit vector variable
module dut (input logic [9:0] i, output logic [31:0] o, output logic [3:0] o2);
  int v;
  bit [3:0] b;
  assign v = signed'(i);
  assign b = unsigned'(i[3:0]);
  assign o = v;
  assign o2 = b;
endmodule
