module m(output logic [3:0] o);
  typedef logic [1:0] l2_t;
  localparam type T = struct packed { reg [1:0] r; l2_t l; };
  T x;
  T [1:0] p;
  assign x = '0; assign p = '0;
  assign o = {x.r, p[1].l};
endmodule
