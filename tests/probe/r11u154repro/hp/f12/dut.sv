// § lvPathBaseAtFirstMember154
module top(input logic [3:0] x);
  localparam int GW = 4;
  typedef struct packed { logic [7:0] wdt; } s_t;
  s_t s;
  assign s.wdt[GW-1:0] = x;
endmodule
