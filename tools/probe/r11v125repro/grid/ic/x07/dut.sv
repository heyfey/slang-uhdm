// § includeFirstLineColShift125
module top(input logic [3:0] a, output logic [3:0] o);
 /* pre */ `include "body.svh"
  assign o = q;
endmodule
