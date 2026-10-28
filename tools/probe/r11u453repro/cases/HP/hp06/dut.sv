// § hpPartSelParenRightEnd453
module top #(parameter int N = 8);
  typedef struct packed { logic [63:0] data; } pkt_s;
  pkt_s s;
  logic [7:0] o;
  assign o = s.data[7:(0)];
endmodule
