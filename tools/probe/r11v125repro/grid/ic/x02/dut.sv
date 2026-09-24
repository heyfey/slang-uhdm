// § includeFirstLineColShift125
module top(input logic [3:0] a, output logic [3:0] o);
  logic z; `include "body.svh"
  assign o = q; assign z = 1;
endmodule
