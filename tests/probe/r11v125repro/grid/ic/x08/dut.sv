// § includeFirstLineColShift125
`define LONGDECL logic [7:0] zz;
module top(input logic [3:0] a, output logic [3:0] o);
`LONGDECL `include "body.svh"
  assign o = q; assign zz = 0;
endmodule
