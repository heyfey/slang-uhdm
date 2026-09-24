`include "hdr.svh"
module top(input logic a, output logic [3:0] o);
  sub u(.a(a), .o(o[1:0]));
  assign o[2] = a;
  assign o[3] = ~a;
endmodule
