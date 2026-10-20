// § hpTrailIpsSysArgNames421
module top #(parameter N = 4) (input logic [3:0] k, output logic [3:0] o);
  typedef struct packed { logic [7:0] cid; logic [3:0] len; } hdr_s;
  hdr_s h;
  assign o = h.cid[0+:$clog2(N)] + h.len[$clog2(N)-:2];
endmodule
