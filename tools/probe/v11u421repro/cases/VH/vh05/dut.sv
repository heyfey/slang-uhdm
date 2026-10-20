// § hpTrailIpsSysArgNames421
module dec #(parameter n = 4) (input [n-1:0] i, output o); assign o = |i; endmodule
module top #(parameter N = 4) (output o);
  typedef struct packed { logic [7:0] cid; logic [3:0] len; } hdr_s;
  hdr_s h;
  dec #(.n(2)) d (.i(h.cid[$clog2(N)+:2]), .o(o));
endmodule
