// $unit wildcard import; a GENERATE block declares a localparam of the same name.
package pv3;
  parameter int STEP = 7;
endpackage
import pv3::*;
module top_v3;
  logic [7:0] x, y;
  assign y = STEP;
  generate
    if (1) begin : gblk
      localparam int STEP = 2;
      assign x = STEP;
    end
  endgenerate
endmodule
