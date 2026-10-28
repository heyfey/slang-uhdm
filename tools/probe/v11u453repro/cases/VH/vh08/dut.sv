// § hpPartSelParenRightEnd453
module top;
  typedef struct packed { logic [63:0] data; } pkt_s;
  pkt_s s;
  always_comb s.data[7:(0)] = 8'h1;
endmodule
