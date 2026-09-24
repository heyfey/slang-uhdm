// § castTsPushLaidOut131
module top (input logic [7:0] a, output logic [5:0] o, output logic [5:0] p);
  assign p = 6'(a); `include "b.svh"
endmodule
