module m(output logic [3:0] o);
  localparam type T = struct packed { logic [3:0] a; };
  T [1:0] p [2];
  T s [3];
  assign p[0] = '0; assign p[1] = '1; assign s[0] = '0; assign s[1] = '0; assign s[2] = '0;
  assign o = p[1][0].a ^ s[2].a;
endmodule
