// § ifacePortDeclTsAtPortDecl205 — r11u217 p09: non-ANSI interface OUTPUT ports with data-type keywords: output logic, output var logic, output reg, output bit, driven in the interface; a parameterized width instantiated twice
interface ifc #(parameter int W = 4) (a, b, c, d);
  output logic [W-1:0] a;
  output var logic [3:0] b;
  output reg [3:0] c;
  output bit [3:0] d;
  assign a = '1;
  assign b = 4'd3;
  assign c = 4'd1;
  assign d = 4'd2;
endinterface
module top (output logic [3:0] y, output logic [7:0] y8, output logic [3:0] z, output logic [3:0] x, output logic [3:0] w);
  logic [3:0] n1, n2, n3;
  ifc u (y, z, x, w);
  ifc #(.W(8)) v (y8, n1, n2, n3);
endmodule
