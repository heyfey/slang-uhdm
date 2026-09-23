interface bi;
  localparam type T = struct packed { logic [3:0] a; logic b; };
  T x;
  T [1:0] p;
endinterface
module m(output logic [3:0] o);
  bi u();
  assign u.x = '0; assign u.p = '0;
  assign o = u.x.a ^ u.p[1].a;
endmodule
