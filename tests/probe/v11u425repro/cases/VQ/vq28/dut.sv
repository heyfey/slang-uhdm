// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
module top(input logic [7:0] a, output logic [7:0] y);
  if (1) begin : g
    wire [7:0] w = p::H;
    wire [7:0] v = p::O;
    assign y = a ^ w ^ v;
  end
endmodule
