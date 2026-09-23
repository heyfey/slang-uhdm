module m(output logic [3:0] o);
  typedef struct packed { logic [1:0] x; logic [1:0] y; } in_t;
  localparam type T = struct packed { in_t i; logic [3:0] b; };
  T v;
  T [1:0] w;
  assign v = '0; assign w = '0;
  assign o = v.i ^ w[1].b;
endmodule
