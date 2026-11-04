// § signCastSysCallLhsTs212 — verifier: a signing cast written inside a macro body and on a line split across two lines
`define SC(x) signed'(x)
module dut (input logic [5:0] i, output logic signed [5:0] o, output logic signed [5:0] o2);
  assign o = `SC(i);
  assign o2 = signed'(
      i);
endmodule
