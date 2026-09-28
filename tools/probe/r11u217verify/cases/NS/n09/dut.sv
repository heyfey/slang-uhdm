// § signCastSysCallLhsTs212 — r11u217 n09: n03 without the interface: signing casts as whole right sides of module continuous assignments onto a signed logic, an unsigned logic, an int and a packed struct variable
typedef struct packed { logic [3:0] a; } s_t;
module dut(input logic [3:0] x, output logic signed [3:0] a, output logic [3:0] b, output int c, output s_t d);
  assign a = signed'(x);
  assign b = unsigned'(a);
  assign c = signed'(x);
  assign d = unsigned'(x);
endmodule
