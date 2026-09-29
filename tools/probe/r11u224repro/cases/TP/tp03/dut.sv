// r11u224 decode: a pattern member whose conditional compares a string
package p;
  typedef struct packed { integer unsigned a; integer unsigned b; } s_t;
  localparam s_t D = '{a: 1, b: 2};
  localparam s_t C = D;
  localparam s_t O = '{a: 5, default: 0};
  localparam s_t R = '{a: (O.a == 0) ? C.a : O.a, b: (O.b == 0) ? C.b : O.b};
endpackage
module top import p::*; (output int o);
  assign o = 1;
endmodule
