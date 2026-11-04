// § hpPartSelParenRightEnd453
module top;
  typedef struct packed { logic [63:0] data; } pkt_s;
  pkt_s [1:0] s;
  logic [7:0] o;
  always_comb o = s[1].data[7:(0)];
endmodule
