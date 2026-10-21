// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
endpackage
module top(input logic [7:0] a, output logic [15:0] y);
  assign y = p::H[7:0] + a;
  wire [15:0] w = p::H + 1;
  wire [15:0] v = -p::O;
endmodule
