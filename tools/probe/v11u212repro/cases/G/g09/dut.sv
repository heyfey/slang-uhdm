// § signCastSysCallLhsTs212 — verifier: a signing cast in a module instantiated inside an interface-typed port context (bind)
module chk (input logic [3:0] i, output logic signed [3:0] o);
  assign o = signed'(i);
endmodule
module dut (input logic [3:0] i, output logic [3:0] o);
  logic signed [3:0] q;
  assign o = q;
endmodule
bind dut chk b (.i(i), .o(q));
