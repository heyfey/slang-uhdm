// § hpTrailIpsSysArgNames421
module top #(parameter N = 4) (output logic [3:0] o);
  typedef struct packed { logic [7:0] cid; logic [3:0] len; } hdr_s;
  typedef struct packed { hdr_s h; logic v; } pk_s;
  pk_s s;
  assign o = s.h.cid[0+:$clog2(N)];
endmodule
