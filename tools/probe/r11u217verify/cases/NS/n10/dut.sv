// § signCastSysCallLhsTs212 — r11u217 n10: a TYPE-PARAMETERIZED child (v11u212 g08) with a signing-cast continuous assignment and a system-call net declaration, instantiated with the default and with an override
module c #(parameter type T = logic [3:0]) (input T x, output T y);
  wire T z = $unsigned(x);
  assign y = signed'(z);
endmodule
module dut(input logic [3:0] x, output logic [3:0] y, output logic [7:0] q);
  c u (.x(x), .y(y));
  c #(.T(logic [7:0])) v (.x({x, x}), .y(q));
endmodule
