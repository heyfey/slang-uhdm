// § hpTrailIpsSysArgNames421
module top #(parameter N = 4) (output logic [3:0] o);
  typedef struct packed { logic [7:0] cid; logic [3:0] len; } hdr_s;
  hdr_s h;
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = |h.cid[i+:$clog2(N)];
  end
endmodule
