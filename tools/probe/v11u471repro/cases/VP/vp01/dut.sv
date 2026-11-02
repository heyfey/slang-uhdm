// § procAsgRhsPkgFoldTs471
// for-loop initializer and a block-local variable initializer
package a;
  parameter int PA = 2;
  parameter logic [3:0] PB = 4'd3;
endpackage
module top(output logic [3:0] y);
  import a::*;
  always_comb begin
    logic [3:0] t = PB;
    y = t;
    for (int i = PA; i < 4; i++) y = y + 4'd1;
  end
endmodule
