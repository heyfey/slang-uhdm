// § hpTrailIpsSysArgNames421
module dec #(parameter n = 4) (input [n-1:0] i, output o); assign o = |i; endmodule
module top #(parameter num_in_p = 4) (output o);
  typedef struct packed { logic [7:0] cid; logic [3:0] len; } hdr_s;
  hdr_s h;
  dec #(.n(num_in_p)) d (.i(h.cid[0+:num_in_p == 1 || num_in_p == 0 ? 1 : $clog2(num_in_p)]), .o(o));
endmodule
