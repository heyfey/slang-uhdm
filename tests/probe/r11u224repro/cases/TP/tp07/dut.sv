// r11u224 decode: a pattern member whose conditional compares a string
module top (output int o);
  typedef struct packed { integer unsigned a; integer unsigned b; } s_t;
  localparam s_t C = '{a: 1, b: 2};
  localparam s_t O = '{a: 5, default: "inv"};
  localparam s_t R = '{a: (O.a == "inv") ? C.a : O.a, b: (O.b == "inv") ? C.b : O.b};
  assign o = R.b;
endmodule
