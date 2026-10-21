// § unszPkgFoldNdaNoTs425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter HX = 'h1F;
  parameter B = 'b101;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
  parameter HU = 'd2_00;
endpackage
interface ifc;
  import p::*;
  wire [7:0] w = H;
  wire [7:0] v = O;
endinterface
module top;
  ifc u();
endmodule
