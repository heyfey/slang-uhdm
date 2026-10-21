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
module top(output logic [7:0] y [2]);
  import p::*;
  for (genvar i = 0; i < 2; i++) begin : g
    wire [7:0] w = H;
    assign y[i] = w;
  end
endmodule
