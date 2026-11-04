// § signCastSysCallLhsTs212 — verifier: a signing cast onto an output port declared non-ANSI
module dut (i, o);
  input [5:0] i;
  output signed [5:0] o;
  assign o = signed'(i);
endmodule
