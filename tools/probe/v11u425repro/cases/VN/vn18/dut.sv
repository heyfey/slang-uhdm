// § unszPkgFoldNdaNoTs425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
interface ifc;
  wire [7:0] w = p::H;
  wire [7:0] v = p::O;
endinterface
module top;
  ifc u();
endmodule
