module m(output logic [3:0] o);
  localparam type T = struct packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; };
  T x;
  T [1:0] p;
  assign x = '0; assign p = '0;
  assign o = {x.b, p[1].b};
endmodule
