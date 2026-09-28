// § signCastSysCallLhsTs212 — r11u217 n03: signing casts as whole right sides of MODULE continuous assignments onto a signed logic, an unsigned logic, an int and a packed struct variable, and inside an INTERFACE (module-only law: control)
typedef struct packed { logic [3:0] a; } s_t;
interface ifc (input logic [3:0] x);
  logic signed [3:0] w;
  assign w = signed'(x);
endinterface
module dut(input logic [3:0] x, output logic signed [3:0] a, output logic [3:0] b, output int c, output s_t d);
  ifc i (.x(x));
  assign a = signed'(x);
  assign b = unsigned'(a);
  assign c = signed'(x);
  assign d = unsigned'(x);
endmodule
