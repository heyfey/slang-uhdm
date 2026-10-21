// § unszBasedPkgFoldUnsized423
package p;
  parameter H = 'h10;
endpackage
import p::*;
module top(input int x, output int y);
  localparam L = H + 1;
  always_comb begin
    y = x * H;
    $display("%d", H);
  end
endmodule
