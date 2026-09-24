module m(output logic [7:0] o);
  localparam type T = struct packed signed { logic [1:0][1:0] a; logic [3:0] b; };
  T x;
  T [2:0] p;
  assign x = '0; assign p = '0;
  assign o = {x.b, p[2].b};
endmodule
