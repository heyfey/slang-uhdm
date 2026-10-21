// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
module top(input logic [31:0] a, output logic [31:0] y);
  for (genvar i = 0; i < p::O; i++) begin : g
    assign y[i] = a[i];
  end
endmodule
