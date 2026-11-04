// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter HX = 'h1F;
  parameter B = 'b101;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
interface ifc(input logic [7:0] a);
  logic [15:0] y;
  assign y = a + p::H;
endinterface
module top(input logic [7:0] a);
  ifc u(.a(a));
endmodule
