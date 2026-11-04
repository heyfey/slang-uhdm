// § unsignedScalarVecTsAtKeyword137
module top(output logic o);
  typedef struct packed { bit unsigned a; logic unsigned b; reg unsigned c; } s_t;
  typedef union packed { bit unsigned a; logic unsigned b; } u_t;
  s_t s; u_t u;
  assign o = s.a ^ u.b;
endmodule
