// § dynAssocMemberSpanToDim295
module top(output logic o);
  typedef struct { int a[], b[string]; } s_t;
  s_t s;
  assign o = 1'b0;
endmodule
