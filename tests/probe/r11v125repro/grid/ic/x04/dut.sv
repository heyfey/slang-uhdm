// § includeInfoRawCol125v
module top(input logic [3:0] a, output logic [3:0] o);
  logic [3:0] r;
   `include "mid.svh"
  assign o = r;
endmodule
