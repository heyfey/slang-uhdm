// r11u224 decode: a pattern member whose conditional compares a string
package p;
  typedef struct packed { integer unsigned a; integer unsigned b; logic [63:0] w1; logic [63:0] w2; } s_t;
  localparam s_t D = '{a: 1, b: 2, default: 0};
  localparam s_t C = D;
  localparam s_t O = '{a: 5, default: "inv"};
  localparam s_t R = '{a: (O.a == "inv") ? C.a : O.a, b: (O.b == "inv") ? C.b : O.b, w1: 0, w2: 0};
endpackage
module top import p::*; (output int o);
  assign o = 1;
endmodule
