// § escIdPpColumnShift146
module top(output logic o);
  typedef enum logic {\A$ , B} e_t;
  e_t v;
  assign v = \A$ ; assign o = (v == B);
endmodule
