module c #(parameter type P = logic) (output logic [3:0] o);
  localparam type T = struct packed { P [3:0] a; };
  T x;
  T [1:0] q;
  assign x = '0; assign q = '0;
  assign o = x.a ^ q[0].a;
endmodule
module m(output logic [3:0] o1, o2);
  c u1(.o(o1));
  c #(.P(bit)) u2(.o(o2));
endmodule
