package pk;
  localparam type T = struct packed { logic [3:0] a; logic b; };
endpackage
module m import pk::*; (output logic [3:0] o);
  T x;
  T [1:0] p;
  assign x = '0; assign p = '0;
  assign o = x.a ^ p[1].a;
endmodule
