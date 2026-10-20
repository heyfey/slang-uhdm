// § hpTrailIpsSysArgNames421
module top #(parameter N = 4) (input logic clk, output logic [3:0] o);
  typedef struct packed { logic [7:0] cid; logic [3:0] len; } hdr_s;
  hdr_s h;
  always_ff @(posedge clk) h.cid[0+:$clog2(N)] <= 2'b1;
  assign o = h.len;
endmodule
