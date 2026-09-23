module m(output logic [3:0] o);
  parameter type T = struct packed { enum logic [1:0] {A, B} e; logic [1:0] b; };
  T [2:0] p;
  assign p = '0;
  assign o = {p[0].b, p[1].b};
endmodule
