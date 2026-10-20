// § hpTrailIpsSysArgNames421
package p; parameter N = 8; endpackage
module top (output logic [3:0] o);
  typedef struct packed { logic [7:0] cid; logic [3:0] len; } hdr_s;
  hdr_s h;
  assign o = h.cid[0+:$clog2(p::N)];
endmodule
