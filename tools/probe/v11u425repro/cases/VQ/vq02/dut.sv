// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter HX = 'h1F;
  parameter B = 'b101;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
module top(output logic [15:0] y, output logic [7:0] z);
  initial begin
    y = p::H;
    z = p::O;
  end
endmodule
