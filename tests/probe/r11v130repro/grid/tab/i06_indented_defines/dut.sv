// § includeLeadTabIsText130v
module top(input logic [3:0] a, output logic [3:0] o);
  `include "defs.svh"
  `include "body.svh"
  assign o = q + `A;
endmodule
