// § strNetRefNotNetSkip422v
// a struct member of the same name read in a continuous assignment
module top(input d, g, output o);
  typedef struct packed { logic c; logic e; } s_t;
  s_t s;
  trireg (large) c;
  assign o = s.c;
  nmos n1 (c, d, g);
endmodule
