// § signCastSysCallLhsTs212 — verifier: a signing cast of a concatenation onto a logic variable, the variable wider than the operand
module dut (input logic [2:0] a, input logic [1:0] b, output logic [7:0] o);
  logic signed [7:0] v;
  assign v = signed'({a, b});
  assign o = v;
endmodule
