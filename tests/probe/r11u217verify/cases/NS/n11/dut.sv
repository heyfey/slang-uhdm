// § signCastSysCallLhsTs212 — r11u217 n11: a BOUND checker module (v11u212 g09) with a signing-cast continuous assignment and a system-call net declaration
module chk (input logic [3:0] x);
  logic signed [3:0] k;
  wire [3:0] m = $signed(x);
  assign k = signed'(m);
endmodule
module dut(input logic [3:0] x, output logic [3:0] y);
  assign y = x;
endmodule
bind dut chk b (.x(x));
