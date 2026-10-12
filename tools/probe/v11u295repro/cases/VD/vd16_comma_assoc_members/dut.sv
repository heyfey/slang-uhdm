// § dynAssocMemberSpanToDim295
module top(output logic o);
  typedef struct { int a[string], b[int]; } s_t;
  s_t s;
  assign o = 1'b0;
endmodule
