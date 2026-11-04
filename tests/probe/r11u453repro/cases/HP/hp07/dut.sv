// § hpPartSelParenRightEnd453
module top;
  typedef struct packed { logic [63:0] data; } pkt_s;
  pkt_s s;
  logic [63:0] o;
  assign o = 64'(s.data[7:(0)]);
endmodule
