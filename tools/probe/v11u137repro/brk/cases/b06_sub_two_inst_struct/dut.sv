// § packedArrTdElemRefName137
module sub(output logic o);
  typedef struct packed { logic a; logic b; } s_t;
  typedef s_t [1:0] sa_t;
  sa_t v;
  assign v = '1;
  assign o = v[0].a;
endmodule
module top(output logic o1, o2);
  sub u1(.o(o1));
  sub u2(.o(o2));
endmodule
