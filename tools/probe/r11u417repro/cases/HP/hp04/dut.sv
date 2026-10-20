// § hierSelParenBoundPretty417
module top (output logic [63:0] o);
  typedef struct packed { logic [63:0] data; } pkt_s;
  pkt_s s;
  int i;
  always_comb o = s.data[(i)+:4];
endmodule
