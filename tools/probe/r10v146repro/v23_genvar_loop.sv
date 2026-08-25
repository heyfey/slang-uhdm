// A generate FOR loop whose genvar-derived localparam shadows the $unit import.
package pv23;
  parameter int IDX = 60;
endpackage
import pv23::*;
module top_v23;
  logic [3:0] o;
  genvar i;
  generate
    for (i = 0; i < 4; i++) begin : gl
      localparam int IDX = i;
      assign o[i] = IDX[0];
    end
  endgenerate
  int z;
  initial z = IDX;
endmodule
