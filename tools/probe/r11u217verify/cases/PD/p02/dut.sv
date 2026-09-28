// § ifacePortDeclTsAtPortDecl205 — r11u217 p02: non-ANSI interface ports with data-type keywords: input bit, input logic signed, output reg, output logic, output wire
interface ifc (b, f, e, g, h);
  input bit [3:0] b;
  input logic signed [3:0] f;
  output reg [3:0] e;
  output logic [3:0] g;
  output wire [3:0] h;
  assign e = b ^ f;
  assign g = b;
  assign h = f;
endinterface
module top (input logic [3:0] i, output logic [3:0] y, output logic [3:0] z, output logic [3:0] x);
  ifc u (.b(i), .f(i), .e(y), .g(z), .h(x));
endmodule
