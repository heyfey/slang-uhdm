module m(output logic [3:0] o);
  typedef struct packed { logic [1:0] a; } in_t;
  localparam type T = struct packed { in_t [1:0] s; logic [1:0] b; };
  T x;
  T [1:0] p;
  assign x = '0; assign p = '0;
  assign o = {x.b, p[1].b};
endmodule
