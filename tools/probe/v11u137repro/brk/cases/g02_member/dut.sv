// § taggedUnionElabSpan137
module top(output logic o);
  typedef struct packed { union tagged packed { logic [1:0] a; logic [1:0] b; } u; logic c; } s_t;
  s_t v;
  assign o = v.c;
endmodule
