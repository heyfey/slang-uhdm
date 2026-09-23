module m(output logic [15:0] o);
  localparam type T = struct packed { logic [3:0] a; logic [3:0] b; };
  T x, y;
  T [1:0] p, q;
  assign x = '0; assign y = '1; assign p = '0; assign q = '1;
  assign o = {x.a, y.b, p[0].a, q[1].b};
endmodule
