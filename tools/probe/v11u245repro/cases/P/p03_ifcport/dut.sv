// § unitTdLawS245
// a $unit int typedef on an interface port and an interface variable
typedef int ui_t;
interface ifc(input ui_t a);
  ui_t b;
  assign b = a + 1;
endinterface
module top(input int i, output int o);
  ifc u(.a(i));
  assign o = u.b;
endmodule
