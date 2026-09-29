// r11u224 decode: a pattern member whose conditional compares a string
package p;
  typedef struct packed { integer unsigned a; integer unsigned b; logic [63:0] w1; logic [63:0] w2; } s_t;
  localparam s_t C = '{a: 1, b: 2, default: 0};
  localparam s_t O = '{a: 5, default: 7};
  localparam s_t R = '{a: (O.a == 7) ? C.a : O.a, b: (O.b == 7) ? C.b : O.b, w1: 0, w2: 0};
endpackage
module top import p::*; (output int o);
  assign o = 1;
endmodule
