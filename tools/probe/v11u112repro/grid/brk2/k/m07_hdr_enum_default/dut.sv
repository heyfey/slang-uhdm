module c #(parameter type T = struct packed { enum logic [1:0] {A, B} e; logic [1:0] b; }) (output logic [1:0] o);
  T x;
  T [1:0] p;
  assign x = '0; assign p = '0;
  assign o = x.b ^ p[1].b;
endmodule
module m(output logic [1:0] o);
  c u(.o(o));
endmodule
