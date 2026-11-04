// § hpPartSelParenRightEnd453
module top;
  typedef struct packed { logic [63:0] data; } pkt_s;
  pkt_s s;
  logic [7:0] o;
  assign s.data[(7):(0)] = o;
endmodule
