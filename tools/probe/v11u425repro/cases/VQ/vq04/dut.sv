// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter HX = 'h1F;
  parameter B = 'b101;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
module top(input logic [7:0] a, output logic y);
  always_comb begin
    case (a)
      p::H: y = 1;
      p::O: y = 0;
      default: y = 0;
    endcase
  end
endmodule
