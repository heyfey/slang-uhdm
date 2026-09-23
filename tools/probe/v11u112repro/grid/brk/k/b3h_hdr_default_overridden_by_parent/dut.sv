module c #(parameter type T = struct packed { logic [3:0] a; }) (output logic [3:0] o);
  T x;
  T [1:0] p;
  assign x = '0; assign p = '0;
  assign o = x.a;
endmodule
module m(output logic [3:0] o1, output logic [3:0] o2);
  typedef struct packed { int a; } si_t;
  c u1(.o(o1));
  c #(.T(si_t)) u2(.o(o2));
endmodule
