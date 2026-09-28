// § signCastSysCallLhsTs212 — r11u217 n05: a TYPE-PARAMETERIZED child and a BOUND checker module (v11u212 g08 / g09: the parse-view names), each with a signing-cast continuous assignment and a system-call net declaration
module c #(parameter type T = logic [3:0]) (input T x, output T y);
  wire T z = $unsigned(x);
  assign y = signed'(z);
endmodule
module chk (input logic [3:0] x);
  logic signed [3:0] k;
  wire [3:0] m = $signed(x);
  assign k = signed'(m);
endmodule
module dut(input logic [3:0] x, output logic [3:0] y, output logic [7:0] q);
  c u (.x(x), .y(y));
  c #(.T(logic [7:0])) v (.x({x, x}), .y(q));
endmodule
bind dut chk b (.x(x));
