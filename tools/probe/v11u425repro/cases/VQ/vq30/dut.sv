// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
module top(input logic [7:0] a, output logic y);
  assign y = (a inside {p::H, [p::O:p::H]});
endmodule
