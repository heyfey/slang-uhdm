// § boundLitUnderscoreDropped186 (typedef, struct member, unpacked size, interface port)
typedef logic [1_5:0] w_t;
interface bus_if(input logic [1_1:0] a);
  logic [0:1_0] b;
endinterface
module top(input logic [11:0] a, output w_t o);
  typedef struct packed { logic [2_3:0] f; logic g; } s_t;
  s_t s;
  logic [3:0] m [1_6];
  bus_if bi(.a(a));
  assign s = '0;
  assign o = s.f[15:0];
endmodule
