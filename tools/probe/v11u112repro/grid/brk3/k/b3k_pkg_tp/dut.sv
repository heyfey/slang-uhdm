package pk;
  localparam type T = struct packed { logic [3:0] a; logic b; };
endpackage
module m(output logic [3:0] o);
  pk::T x;
  pk::T [1:0] p;
  assign x = '0; assign p = '0;
  assign o = x.a ^ p[1].a;
endmodule
