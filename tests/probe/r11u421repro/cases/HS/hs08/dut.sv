// § hpTrailIpsSysArgNames421
module top #(parameter num_in_p = 4) (output logic [3:0] o);
  typedef struct packed { logic [7:0] cid; logic [3:0] len; } hdr_s;
  hdr_s h;
  always_comb o = h.cid[$clog2(num_in_p)+:2];
endmodule
