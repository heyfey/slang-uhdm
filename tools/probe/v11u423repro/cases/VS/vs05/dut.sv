// § unszBasedPkgFoldUnsized423
package p;
  parameter H = 'h3;
endpackage
module top(input logic [3:0] x, output logic y, output logic [7:0] q);
  import p::*;
  logic [7:0] a;
  always_comb begin
    case (x)
      H: y = 1'b1;
      default: y = 1'b0;
    endcase
    if (x == H) q = a[H];
    else q = 8'd0;
  end
endmodule
