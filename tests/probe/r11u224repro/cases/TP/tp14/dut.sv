// r11u224 decode: a pattern member whose conditional compares a string
package p;
  typedef struct packed { integer unsigned a; integer unsigned b; integer unsigned f; } s_t;
  localparam s_t C = '{a: 1, b: 2, f: (1 << 2) | (1 << 3)};
  localparam s_t R = '{a: C.a, b: C.b, f: 0};
endpackage
module top import p::*; (output int o);
  assign o = 1;
endmodule
