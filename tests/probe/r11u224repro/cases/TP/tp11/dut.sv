// r11u224 decode: a pattern member whose conditional compares a string
package p;
  typedef struct packed { integer unsigned a; integer unsigned b; logic [63:0] w1; logic [63:0] w2; } s_t;
  localparam s_t C = '{a: 1, b: 2, default: 0};
  localparam s_t R = '{a: C.a, b: C.b, w1: 0, w2: 0};
endpackage
module top import p::*; (output int o);
  assign o = 1;
endmodule
