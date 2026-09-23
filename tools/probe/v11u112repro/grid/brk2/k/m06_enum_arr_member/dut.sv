module m(output logic [3:0] o);
  typedef enum logic [1:0] {A, B} e_t;
  localparam type T = struct packed { e_t [1:0] e; logic [1:0] b; };
  T [1:0] p;
  assign p = '0;
  assign o = {p[0].b, p[1].b};
endmodule
