// § hpPartSelParenRightEnd453
module top;
  typedef struct packed { struct packed { logic [15:0] d; } in; } pkt_s;
  pkt_s s;
  logic [7:0] o;
  assign o = s.in.d[7:(0)];
endmodule
