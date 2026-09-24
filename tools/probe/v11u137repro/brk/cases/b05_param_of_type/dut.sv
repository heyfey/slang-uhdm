// § packedArrTdElemRefName137
module top(output logic o);
  typedef struct packed { logic a; logic b; } s_t;
  typedef s_t [1:0] sa_t;
  parameter sa_t P = '0;
  sa_t v;
  assign o = v[0].a ^ P[1].b;
endmodule
