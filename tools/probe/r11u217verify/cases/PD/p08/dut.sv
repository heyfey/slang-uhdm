// § ifacePortDeclTsAtPortDecl205 — r11u217 p08: non-ANSI interface OUTPUT ports with the net-type keywords tri, wor, wand and wire signed, each driven in the interface
interface ifc (a, b, c, d);
  output tri [7:4] a;
  output wor [3:0] b;
  output wand [5:2] c;
  output wire signed [3:0] d;
  assign a = 4'd9;
  assign b = 4'd3;
  assign c = 4'd1;
  assign d = -4'sd2;
endinterface
module top (output logic [3:0] y, output logic [3:0] z, output logic [3:0] x, output logic [3:0] w);
  ifc u (y, z, x, w);
endmodule
